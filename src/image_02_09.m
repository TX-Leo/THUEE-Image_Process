my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat'); %hall_gray
    load('../resource/JpegCoeff.mat');%QTAB DCTAB ACTAB

    image = double(hall_gray) - 128;
    % 获得量化后的系数矩阵
    coefficient_matrix = my_block_and_dct_and_quantization(image,QTAB);
    % get the DC系数的码流
    dc_stream = my_get_dc_stream(coefficient_matrix,DCTAB);
    % get the AC系数的码流
    ac_stream = my_get_ac_stream(coefficient_matrix,ACTAB);
    % get the height of a image
    image_height = my_get_image_height(hall_gray);
    % get the width of a image
    image_width = my_get_image_width(hall_gray);
    % save parameters
    save('../generated_photo/jpegcodes.mat', 'dc_stream', 'ac_stream', 'image_height', 'image_width');
    load('../generated_photo/jpegcodes.mat');
    % disp
    disp(dc_stream);
    disp(ac_stream);
    disp(image_height);
    disp(image_width);
end
% 对测试图像分块、DCT和量化，获得量化后的系数矩阵（其中每一列为一个块的DCT系数Zig-Zag扫描后形成的列矢量，第一行为各个块的DC系数）
function coefficient_matrix = my_block_and_dct_and_quantization(image,QTAB)
    image_changed = blockproc(image, [8, 8], @(blk) my_zigzag_scan(round(dct2(blk.data) ./ QTAB)));
    [height, width]  =size(image_changed);
    coefficient_matrix = zeros([64, height / 64 * width]);
    for i = 1 : 1 : height / 64
        coefficient_matrix(:, (i - 1) * width + 1 : i * width) = image_changed((i - 1) * 64 + 1 : i * 64, 1 : width);
    end
end
% 实现对于输入一个8*8的矩阵，输出为z字形扫描的结果
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
% dec 2 binary
function y = dec2bin_array(x)
    if x == 0
        y = [];
    else
        y = double(dec2bin(abs(x))) - '0';
        if x < 0
            y = ~y;
        end
    end
end
% get the DC系数的码流
function dc_stream = my_get_dc_stream(coefficient_matrix,DCTAB)
    dc = coefficient_matrix(1, :)';
    diff_dc = [dc(1); -diff(dc)];
    category_plus_one = min(ceil(log2(abs(diff_dc) + 1)), 11) + 1;
    dc_stream = arrayfun(@(i) [DCTAB(category_plus_one(i), 2 : DCTAB(category_plus_one(i), 1) + 1),dec2bin_array(diff_dc(i))]',[1 : length(diff_dc)]', 'UniformOutput', false);
    dc_stream = cell2mat(dc_stream);
end
% get the AC系数的码流
function ac_stream = my_get_ac_stream(coefficient_matrix,ACTAB)
    ac = coefficient_matrix(2 : end, :);
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
            ac_stream = [ac_stream, repmat(ZRL, num_of_ZRL, 1), ACTAB(this_tab_row, 4 : ACTAB(this_tab_row, 3) + 3), dec2bin_array(this_ac(new_idx))];
            not_zero(new_idx) = 0;
            last_not_zero_idx = new_idx;
        end
        ac_stream = [ac_stream, EOB];
    end
    ac_stream = ac_stream';
end
% get the height of a image
function image_height = my_get_image_height(image)
    image_height = size(image, 1);
end
% get the width of a image
function image_width = my_get_image_width(image)
    image_width = size(image, 2);
end
