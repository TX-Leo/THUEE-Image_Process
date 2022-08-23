my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');% hall_gray
    load('../resource/JpegCoeff.mat');% DCTAB, ACTAB, QTAB
    % DCT域信息隐藏技术
    my_dct_domain_information_hiding_technology(hall_gray,DCTAB, ACTAB, QTAB);
end
% DCT域信息隐藏技术
function my_dct_domain_information_hiding_technology(image,DCTAB, ACTAB, QTAB)
    [C_tilde,image_height, image_width] = my_jpeg_process(image,QTAB);
    info1 = randi([0, 1], size(C_tilde, 1), size(C_tilde, 2));% 1*315
    info23 = randi([0, 1], 1, size(C_tilde, 2)); % 1*315
    [image_res1,dc_stream1,ac_stream1,find_info1] = my_dct_domain_information_hiding_technology_01(info1,C_tilde,image_height,image_width,QTAB,DCTAB,ACTAB);
    [image_res2,dc_stream2,ac_stream2,find_info2] = my_dct_domain_information_hiding_technology_02(info23,C_tilde,image_height,image_width,QTAB,DCTAB,ACTAB);
    [image_res3,dc_stream3,ac_stream3,find_info3] = my_dct_domain_information_hiding_technology_03(info23,C_tilde,image_height,image_width,QTAB,DCTAB,ACTAB);
    [ratios,psnrs,accuracies] = my_calculate(dc_stream1,ac_stream1,dc_stream2,ac_stream2,dc_stream3,ac_stream3,image,image_res1,image_res2,image_res3,info1,info23,find_info1,find_info2,find_info3);
    my_plot(image,image_res1,image_res2,image_res3);
    %disp('info1');
    %info1
    %disp('info23');
    %info23
    %disp('find info1');
    %find_info1
    %disp('find info2');
    %find_info2
    %disp('find info3');
    %find_info3
end
% jpeg处理
function [C_tilde,image_height, image_width] = my_jpeg_process(image,QTAB)
    img2proc = double(image) - 128;
    [image_height, image_width] = size(img2proc);
    [~, ~, img2proc] = my_image_padding(image_height, image_width, 8, 8, img2proc);
    C = blockproc(img2proc, [8, 8], @(blk) my_zigzag_scan(round(dct2(blk.data) ./ QTAB)));
    [h, w] = size(C);
    hp = h / 64;
    C_tilde = zeros([64, hp * w]);
    for i = 1 : 1 : hp
        C_tilde(:, (i - 1) * w + 1 : i * w) = C((i - 1) * 64 + 1 : i * 64, 1 : w);
    end
end
% DCT域信息隐藏技术01-用信息位逐一替换掉每个量 化后的 DCT 系数的最低位，再行熵编码
function [image_res1,dc_stream1,ac_stream1,find_info1] = my_dct_domain_information_hiding_technology_01(info1,C_tilde,image_height,image_width,QTAB,DCTAB,ACTAB)
    h = image_height;
    w = image_width;
    hp = h / 8;
    wp = w / 8;
    C_hide_01 = my_hide_01(C_tilde, info1);
    dc_stream1 = my_dc_encode(C_hide_01(1, :)', DCTAB);
    ac_stream1 = my_ac_encode(C_hide_01(2 : end, :), ACTAB);
    dc_cum1 = my_dc_decode(dc_stream1, hp * wp, DCTAB);
    ac_decoding_res1 = my_ac_decode(ac_stream1, hp * wp, ACTAB);
    decoding_res1 = [dc_cum1'; ac_decoding_res1];
    find_info1 = my_find1(decoding_res1);
    decoding_C1 = zeros(64 * hp, wp);
    for i = 1 : 1 : hp
        decoding_C1((i - 1) * 64 + 1 : i * 64, :) = decoding_res1(:, (i - 1) * wp + 1 : i * wp);
    end
    decoding1 = blockproc(decoding_C1, [64, 1], @(blk) idct2(my_inverse_zigzag_scan(blk.data) .* QTAB));
    decoding_img1 = uint8(decoding1 + 128);
    image_res1 = decoding_img1(1 : image_height, 1 : image_width);
end
% DCT域信息隐藏技术02-用信息位逐一替换掉若干量化后的DCT系数的最低位，再行熵编码
function [image_res2,dc_stream2,ac_stream2,find_info2] = my_dct_domain_information_hiding_technology_02(info23,C_tilde,image_height,image_width,QTAB,DCTAB,ACTAB)
    h = image_height;
    w = image_width;
    hp = h / 8;
    wp = w / 8;
    C_hide_02 = my_hide_02(C_tilde, info23, QTAB);
    dc_stream2 = my_dc_encode(C_hide_02(1, :)', DCTAB);
    ac_stream2 = my_ac_encode(C_hide_02(2 : end, :), ACTAB);
    dc_cum2 = my_dc_decode(dc_stream2, hp * wp, DCTAB);
    ac_decoding_res2 = my_ac_decode(ac_stream2, hp * wp, ACTAB);
    decoding_res2 = [dc_cum2'; ac_decoding_res2];
    find_info2 = my_find2(decoding_res2, QTAB);
    decoding_C2 = zeros(64 * hp, wp);
    for i = 1 : 1 : hp
        decoding_C2((i - 1) * 64 + 1 : i * 64, :) = decoding_res2(:, (i - 1) * wp + 1 : i * wp);
    end
    decoding2 = blockproc(decoding_C2, [64, 1], @(blk) idct2(my_inverse_zigzag_scan(blk.data) .* QTAB));
    decoding_img2 = uint8(decoding2 + 128);
    image_res2 = decoding_img2(1 : image_height, 1 : image_width);
end
% DCT域信息隐藏技术03-先将待隐藏信息用1,-1 的序列表示，再逐一将信息位追加在每个块Zig-Zag顺序的最后一个非零DCT系数之后；如果原本该图像块的最后一个系数就不为零，那就用信息位替换该系数
function [image_res3,dc_stream3,ac_stream3,find_info3] = my_dct_domain_information_hiding_technology_03(info23,C_tilde,image_height,image_width,QTAB,DCTAB,ACTAB)
    h = image_height;
    w = image_width;
    hp = h / 8;
    wp = w / 8;
    C_hide_03 = my_hide_03(C_tilde, info23);
    dc_stream3 = my_dc_encode(C_hide_03(1, :)', DCTAB);
    ac_stream3 = my_ac_encode(C_hide_03(2 : end, :), ACTAB);
    dc_cum3 = my_dc_decode(dc_stream3, hp * wp, DCTAB);
    ac_decoding_res3 = my_ac_decode(ac_stream3, hp * wp, ACTAB);
    decoding_res3 = [dc_cum3'; ac_decoding_res3];
    find_info3 = my_find3(decoding_res3);
    decoding_C3 = zeros(64 * hp, wp);
    for i = 1 : 1 : hp
        decoding_C3((i - 1) * 64 + 1 : i * 64, :) = decoding_res3(:, (i - 1) * wp + 1 : i * wp);
    end
    decoding3 = blockproc(decoding_C3, [64, 1], @(blk) idct2(my_inverse_zigzag_scan(blk.data) .* QTAB));
    decoding_img3 = uint8(decoding3 + 128);
    image_res3 = decoding_img3(1 : image_height, 1 : image_width);
end
% 第一种隐藏方法
function Out = my_hide_01(In, info)
    Out = double(bitset(int64(round(In)), 1, info));
end
% 第二种隐藏方法
function Out = my_hide_02(In, info, QTAB)
    [~, min_idx] = min(my_zigzag_scan(QTAB));
    In(min_idx, :) = double(bitset(int64(round(In(min_idx, :))), 1, info));
    Out = In;
end
% 第三种隐藏方法
function Out = my_hide_03(In, info)
    info = double(info);
    info(info == 0) = -1;
    Out = zeros(size(In));
    for i = 1 : 1 : size(In, 2)
        this_seq = In(:, i);
        if this_seq == 0
            Out(:, i) = [info(i); In(2 : end, i)];
        else
            not_zero = flipud(this_seq ~= 0);
            this_seq = flipud(this_seq);
            [~, idx] = max(not_zero);
            if idx == 1
                this_seq(1) = info(i);
            else
                this_seq(idx - 1) = info(i);
            end
            Out(:, i) = flipud(this_seq);
        end
    end
end
% 第一种寻找方法
function info = my_find1(In)
    info = uint8(bitget(int64(round(In)), 1));
end
% 第二种寻找方法
function info = my_find2(In, QTAB)
    [~, min_idx] = min(my_zigzag_scan(QTAB));
    info = uint8(bitget(int64(round(In(min_idx, :))), 1));
end
% 第三种寻找方法
function info = my_find3(In)
    info = uint8(zeros([1, size(In, 2)]));
    for i = 1 : 1 : size(In, 2)
        this_seq = flipud(In(:, i));
        if this_seq == 0
            info(i) = 0;    % error
            disp('Warning: Get message error: All is zero!');
        else
            is_zero = this_seq ~= 0;
            [~, idx] = max(is_zero);
            if this_seq(idx) == 1
                info(i) = 1;
            elseif this_seq(idx) == -1
                info(i) = 0;
            else
                info(i) = 0;    % error
                disp('Warning: Get message error: Not 1 or -1!');
            end
        end
    end
end
% 计算压缩比&PSNR&隐藏后寻找的准确率
function [ratios,psnrs,accuracies] = my_calculate(dc_stream1,ac_stream1,dc_stream2,ac_stream2,dc_stream3,ac_stream3,hall_gray,image_res1,image_res2,image_res3,info1,info23,find_info1,find_info2,find_info3)
    ratios = [my_get_compress_ratio(hall_gray,dc_stream1, ac_stream1), my_get_compress_ratio(hall_gray,dc_stream2, ac_stream2), my_get_compress_ratio(hall_gray,dc_stream3, ac_stream3)];
    psnrs = [my_get_psnr(hall_gray, image_res1), my_get_psnr(hall_gray, image_res2), my_get_psnr(hall_gray, image_res3)];
    accuracies = [sum(info1  == find_info1, 'all') / (size(info1 , 1) * size(info1 , 2)),sum(info23 == find_info2, 'all') / (size(info23, 1) * size(info23, 2)),sum(info23 == find_info3, 'all') / (size(info23, 1) * size(info23, 2))];
    disp('Compress ratio: ');
    disp(ratios);
    disp('PSNR: ');
    disp(psnrs);
    disp('Accuracy: ');
    disp(accuracies);
end
% 画图
function my_plot(hall_gray,image_res1,image_res2,image_res3)
    subplot(2, 2, 1);
    imshow(hall_gray);
    title('original image');
    subplot(2, 2, 2);
    imshow(image_res1);
    title('image1 after hiding info');
    subplot(2, 2, 3);
    imshow(image_res2);
    title('image2 after hiding info');
    subplot(2, 2, 4);
    imshow(image_res3);
    title('image3 after hiding info');
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