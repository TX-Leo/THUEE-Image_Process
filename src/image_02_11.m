my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../generated_photo/jpegcodes.mat');
    load('../resource/JpegCoeff.mat');
    load('../resource/hall.mat');
    hp = image_height / 8;
    wp = image_width / 8;
    num_of_blocks = image_height / 8 * image_width / 8;
    dc_cum = my_dc_decode(dc_stream,num_of_blocks,DCTAB);
    ac_decoding_res = my_ac_decode(ac_stream, num_of_blocks, ACTAB);
    decoding_C = my_realignment(dc_cum,ac_decoding_res,hp,wp);
    decoding_img = my_inverse_block_and_dct_and_quantization(decoding_C,QTAB);
    my_calculate_PSNR(decoding_img,hall_gray,image_height,image_width);
    my_plot(hall_gray,decoding_img);
end
% DC Decoding
function dc_cum = my_dc_decode(dc_stream,num_of_blocks,DCTAB)
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
    dc_cum = cumsum([dc_decoding_res(1); -dc_decoding_res(2:end)]);
end
% AC decoding
function ac_decoding_res = my_ac_decode(ac_stream, num_of_blocks, ACTAB)
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
end
% DC 和 AC 解码得到的结果拼合成矩阵，然后将结果按逐行重新排列为图片的行、列分布
function decoding_C = my_realignment(dc_cum,ac_decoding_res,hp,wp)
    decoding_res = [dc_cum'; ac_decoding_res];
    decoding_C = zeros(64 * hp, wp);
    for i = 1 : 1 : hp
        decoding_C((i - 1) * 64 + 1 : i * 64, :) = decoding_res(:, (i - 1) * wp + 1 : i * wp);
    end
end
% 依次分块进行反 Zig-Zag、反量化、离散余弦逆变换
function decoding_img = my_inverse_block_and_dct_and_quantization(decoding_C,QTAB)
    decoding = blockproc(decoding_C, [64, 1], @(blk) idct2(my_inverse_zigzag_scan(blk.data) .* QTAB));
    decoding_img = uint8(decoding + 128);
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
% 计算PSNR
function my_calculate_PSNR(decoding_img,hall_gray,image_height,image_width)
    MSE = sum((double(decoding_img) - double(hall_gray)).^2, 'all') / (image_height * image_width);
    PSNR = 10 * log10(255 * 255 / MSE);
    disp("PSNR = " + PSNR);
end
% 画图
function my_plot(hall_gray,decoding_img)
    subplot(1, 2, 1);
    imshow(hall_gray);
    title('hall gray');
    subplot(1, 2, 2);
    imshow(decoding_img);
    title('hall gray after decoding');
end

