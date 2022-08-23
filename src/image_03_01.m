my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');% hall_gray
    load('../resource/JpegCoeff.mat');% DCTAB, ACTAB, QTAB
    % information要隐藏的信息(height*width的大小)
    [height, width] = size(hall_gray);
    %information = uint8(randi([0, 1], height, width));% 01随机序列
    %information = uint8(ones([height, width])); % 全1序列
    information = uint8(zeros([height, width])); %全0序列
    % 对信息进行空域隐藏
    my_airspace_information_hiding_technology(information,hall_gray,DCTAB, ACTAB, QTAB);
end

function my_airspace_information_hiding_technology(information,image,DCTAB, ACTAB, QTAB)
    repeat_time = 20;
    [height, width] = size(image);
    correct_ratio = zeros([repeat_time, 1]);
    for i = 1 : 1 : repeat_time
        secret_image = bitset(image, 1, information);
        subplot(1,3,3);
        imshow(secret_image);
        title('image after hide information');
        decoding_image = my_process_image(secret_image,DCTAB, ACTAB, QTAB);
        decoding_information = bitand(decoding_image, uint8(ones([height, width])));
        correct_information = ~xor(information, decoding_information);
        correct_ratio(i) = sum(correct_information, 'all') / (height * width);
    end
    disp("Ratio: ");
    disp(correct_ratio');
    disp("Average: " + mean(correct_ratio));
end
function image_res = my_process_image(image,DCTAB, ACTAB, QTAB)
    % 量化步长减小为原来的一半
    % QTAB = QTAB / 2; 
    %编解码
    [dc_stream, ac_stream, image_height, image_width, image_res] = my_jpeg_encode_and_decode(image, DCTAB, ACTAB, QTAB);
    % 计算压缩比
    disp("Compress ratio = " + my_get_compress_ratio(image,dc_stream,ac_stream));
    % 计算PSNR
    disp("PSNR = " + my_get_psnr(image, image_res));
    %画图
    my_plot(image,image_res);
end
function [dc_stream, ac_stream, image_height, image_width, image_res] = my_jpeg_encode_and_decode(hall_gray, DCTAB, ACTAB, QTAB)
    [dc_stream, ac_stream, image_height, image_width] = my_jpeg_encode(hall_gray, DCTAB, ACTAB, QTAB);
    image_res = my_jpeg_decode(dc_stream, ac_stream, image_height, image_width, DCTAB, ACTAB, QTAB);
end
% 画图
function my_plot(hall_gray,image_res)
    subplot(1, 3, 1);
    imshow(hall_gray);
    title('original image');
    subplot(1, 3, 2);
    imshow(image_res);
    title('image after encoding and decoding');
end
% jpeg encode
function [dc_stream, ac_stream, image_height, image_width] = my_jpeg_encode(input_img, DCTAB, ACTAB, QTAB)
    img2proc = double(input_img) - 128;
    [image_height, image_width] = size(img2proc);
    [~, ~, img2proc] = my_image_padding(image_height, image_width, 8, 8, img2proc);
    C = blockproc(img2proc, [8, 8], @(blk) my_zigzag_scan(round(dct2(blk.data) ./ QTAB)));
    [height, width] = size(C);
    hp = height / 64;
    C_tilde = zeros([64, hp * width]);
    for i = 1 : 1 : hp
        C_tilde(:, (i - 1) * width + 1 : i * width) = C((i - 1) * 64 + 1 : i * 64, 1 : width);
    end
    dc_stream = my_dc_encode(C_tilde(1, :)', DCTAB);
    ac_stream = my_ac_encode(C_tilde(2 : end, :), ACTAB);
end
% jpeg decode
function image_res = my_jpeg_decode(dc_stream, ac_stream, image_height, image_width, DCTAB, ACTAB, QTAB)
    [height, width, ~] = my_image_padding(image_height, image_width, 8, 8, zeros(image_height, image_width));
    hp = height / 8;
    wp = width / 8;
    dc_cum = my_dc_decode(dc_stream, hp * wp, DCTAB);
    ac_decoding_res = my_ac_decode(ac_stream, hp * wp, ACTAB);
    
    decoding_res = [dc_cum'; ac_decoding_res];
    decoding_C = zeros(64 * hp, wp);
    for i = 1 : 1 : hp
        decoding_C((i - 1) * 64 + 1 : i * 64, :) = decoding_res(:, (i - 1) * wp + 1 : i * wp);
    end
    decoding = blockproc(decoding_C, [64, 1], @(blk) idct2(my_inverse_zigzag_scan(blk.data) .* QTAB));
    decoding_img = uint8(decoding + 128);
    image_res = decoding_img(1 : image_height, 1 : image_width);
end
% image padding
function [h_res, w_res, image_res] = my_image_padding(height, width, h_base, w_base, image)
    pad = false;
    if mod(height, h_base) ~= 0
        h_padding = h_base - height;
        img2proc = [img2proc; zeros(h_padding, width)];
        h_res = height + h_padding;
        pad = true;
    else
        h_res = height;
    end
    if mod(width, w_base) ~= 0
        w_padding = w_base - width;
        img2proc = [img2proc, zeros(height, w_padding)];
        w_res = width + w_padding
        pad = true;
    else
        w_res = width;
    end
    if pad == true
        image_res = zeros([h_res, w_res]);
        image_res(1 : height, 1 : width) = image;
    else
        image_res = image;
    end
end
% 正zigzag
function y = my_zigzag_scan(x)
    order = [ ...
         1,  2,  6,  7, 15, 16, 28, 29; ...
         3,  5,  8, 14, 17, 27, 30, 43; ...
         4,  9, 13, 18, 26, 31, 42, 44; ...
        10, 12, 19, 25, 32, 41, 45, 54; ...
        11, 20, 24, 33, 40, 46, 53, 55; ...
        21, 23, 34, 39, 47, 52, 56, 61; ...
        22, 35, 38, 48, 51, 57, 60, 62; ...
        36, 37, 49, 50, 58, 59, 63, 64];
    idx(order) = reshape([1 : 64], 8, 8);
    y = x(idx)';
end
% 反zigzag
function y = my_inverse_zigzag_scan(x)
    order = [ ...
         1,  2,  6,  7, 15, 16, 28, 29; ...
         3,  5,  8, 14, 17, 27, 30, 43; ...
         4,  9, 13, 18, 26, 31, 42, 44; ...
        10, 12, 19, 25, 32, 41, 45, 54; ...
        11, 20, 24, 33, 40, 46, 53, 55; ...
        21, 23, 34, 39, 47, 52, 56, 61; ...
        22, 35, 38, 48, 51, 57, 60, 62; ...
        36, 37, 49, 50, 58, 59, 63, 64];
    idx(order) = reshape([1 : 64], 8, 8);
    y(idx) = x;
    y = reshape(y, 8, 8);
end
% ac decode
function res = my_ac_decode(ac_stream, num_of_blocks, ACTAB)
    ZRL = [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1];
    EOB = [1, 0, 1, 0];
    ac_decoding_res = zeros([63, num_of_blocks]);
    i = 1;
    block_cnt = 1;
    inner_block_cnt = 1;
    while i < length(ac_stream)
        if i + length(ZRL) - 1 <= length(ac_stream) && sum(~(ac_stream(i : i + length(ZRL) - 1) == ZRL')) == 0
            inner_block_cnt = inner_block_cnt + 16;
            i = i + length(ZRL);
        elseif i + length(EOB) - 1 <= length(ac_stream) && sum(~(ac_stream(i : i + length(EOB) - 1) == EOB')) == 0
            block_cnt = block_cnt + 1;
            inner_block_cnt = 1;
            i = i + length(EOB);
        else
            for j = 1 : 1 : size(ACTAB, 1)
                if i + ACTAB(j, 3) - 1 > length(ac_stream)
                    continue;
                end
                if ACTAB(j, 4 : ACTAB(j, 3) + 3) == ac_stream(i : i + ACTAB(j, 3) - 1)'
                    inner_block_cnt = inner_block_cnt + ACTAB(j, 1);
                    i = i + ACTAB(j, 3);
                    Amplitude = ac_stream(i : i + ACTAB(j, 2) - 1);
                    if Amplitude(1) == 1
                        ac_decoding_res(inner_block_cnt, block_cnt) = bin2dec(char(Amplitude' + '0'));
                    else
                        ac_decoding_res(inner_block_cnt, block_cnt) = -bin2dec(char(~Amplitude' + '0'));
                    end
                    i = i + ACTAB(j, 2);
                    inner_block_cnt = inner_block_cnt + 1;
                    break;
                end
            end
        end
    end
    res = ac_decoding_res;
end
% ac encode
function ac_stream = my_ac_encode(ac, ACTAB)
    Size = min(ceil(log2(abs(ac) + 1)), 10);
    ac_stream = [];
    ZRL = [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1];
    EOB = [1, 0, 1, 0];
    for i = 1 : 1 : size(ac, 2)
        this_ac = ac(:, i);
        this_Size = Size(:, i);
        last_not_zero_idx = 0;
        not_zero = this_ac ~= 0;
        while sum(not_zero) ~= 0
            [~, new_idx] = max(not_zero);
            Run = new_idx - last_not_zero_idx - 1;
            num_of_ZRL = floor(Run / 16);
            Run = mod(Run, 16);
            this_tab_row = Run * 10 + this_Size(new_idx);
            ac_stream = [ac_stream, repmat(ZRL, num_of_ZRL, 1), ACTAB(this_tab_row, 4 : ACTAB(this_tab_row, 3) + 3), my_dec2bin_array(this_ac(new_idx))];
            not_zero(new_idx) = 0;
            last_not_zero_idx = new_idx;
        end
        ac_stream = [ac_stream, EOB];
    end
    ac_stream = ac_stream';
end
% dc decode
function res = my_dc_decode(dc_stream, num_of_blocks, DCTAB)
    dc_decoding_res = zeros([num_of_blocks, 1]);
    i = 1;
    cnt = 1;
    while i <= length(dc_stream)
        for j = 1 : 1 : size(DCTAB, 1)
            % Omitted overbound judge here!!!

            if DCTAB(j, 2 : DCTAB(j, 1) + 1)' == dc_stream(i : i + DCTAB(j, 1) - 1)
                i = i + DCTAB(j, 1);
                category = j - 1;
                if category ~= 0
                    Magnitude = dc_stream(i : i + category - 1);
                    if Magnitude(1) == 1
                        dc_decoding_res(cnt) = bin2dec(char(Magnitude' + '0'));
                    else
                        dc_decoding_res(cnt) = -bin2dec(char(~Magnitude' + '0'));
                    end
                end
                i = i + category;
                break;
            end
        end
        cnt = cnt + 1;
    end
    res = cumsum([dc_decoding_res(1); -dc_decoding_res(2:end)]);
end
% dc encode
function dc_stream = my_dc_encode(dc, DCTAB)
    diff_dc = [dc(1); -diff(dc)];
    category_plus_one = min(ceil(log2(abs(diff_dc) + 1)), 11) + 1;

    dc_stream = arrayfun(@(i) ...
        [DCTAB(category_plus_one(i), 2 : DCTAB(category_plus_one(i), 1) + 1), ...
        my_dec2bin_array(diff_dc(i))]', ...
        [1 : length(diff_dc)]', 'UniformOutput', false);
    dc_stream = cell2mat(dc_stream);
end
% 输出psnr
function psnr_val = my_get_psnr(org_img, decoding_img)
    MSE = sum((double(decoding_img) - double(org_img)).^2, 'all') / (size(org_img, 1) * size(org_img, 2));
    psnr_val = 10 * log10(255 * 255 / MSE);
end
% 输出压缩比
function ratio = my_get_compress_ratio(hall_gray,dc_stream,ac_stream)
    ratio = (size(hall_gray, 1) * size(hall_gray, 2)) / ((length(dc_stream) + length(ac_stream)) / 8);
end
% dec2bin for array
function y = my_dec2bin_array(x)
    if x == 0
        y = [];
    else
        y = double(dec2bin(abs(x))) - '0';
        if x < 0
            y = ~y;
        end
    end
end
