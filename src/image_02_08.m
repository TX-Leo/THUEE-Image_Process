my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');
    load('../resource/JpegCoeff.mat');
    image = double(hall_gray) - 128;
    % 获得量化后的系数矩阵
    coefficient_matrix = my_block_and_dct_and_quantization(image,QTAB);
    disp(coefficient_matrix);
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
