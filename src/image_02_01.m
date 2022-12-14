my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');
    % 取 hall_gray 的左上角的 8*8 的部分进行验证
    image = double(hall_gray(1:8, 1:8));
    % 采用直接相减128再dct
    image1 = my_change_gray_value_1(image)
    % 采用减去全为128的矩阵的dct
    image2 = my_change_gray_value_2(image)
    % 误差采用各个元素误差的平方之和进行度量
    disp(sum((image1 - image2).^2, 'all'));
end
% 将每个像素的灰度值减去128方法1
function image_changed = my_change_gray_value_1(image)
    % image_changed采用直接相减128再dct
    image_changed = dct2(image - 128);
    disp('image_changed');
    image_changed
    % 919.7500    8.7800   -9.7500    2.1117   -4.0000    1.8469   -0.0204   -0.4074
    % 17.1450    5.7528    1.5922    2.1679    2.4500    0.3589   -0.9249    0.6849
    % 10.8488   -9.6854   -1.0089   -2.0173   -1.7125    0.8604   -0.3750   -0.3638
    %  1.9176    5.5195    0.7804    0.4169    1.0319    2.1320   -0.0983    0.1123
    % -6.2500   -4.5243    2.3261   -1.2496    2.0000   -0.2959    0.3895   -0.0824
    % -0.2737    1.1251   -2.4865    1.1016    1.1876   -1.8792    1.1803   -0.3821
    % -1.2465    1.2015    0.3750   -0.1294    0.4387   -2.3145    0.7589    0.4292
    %  0.6502    0.6545   -0.9012   -0.9573   -1.9742    0.9304    0.3205    0.2095
end
% 将每个像素的灰度值减去128方法2
function image_changed = my_change_gray_value_2(image)
    % image_changed采用减去全为128的矩阵的dct
    image_changed = dct2(image);
    temp = dct2(zeros([8, 8]) + 128);
    image_changed(1, 1) = image_changed(1, 1) - temp(1, 1);
    disp('image_changed')
    image_changed
    % 919.7500    8.7800   -9.7500    2.1117   -4.0000    1.8469   -0.0204   -0.4074
    % 17.1450    5.7528    1.5922    2.1679    2.4500    0.3589   -0.9249    0.6849
    % 10.8488   -9.6854   -1.0089   -2.0173   -1.7125    0.8604   -0.3750   -0.3638
    %  1.9176    5.5195    0.7804    0.4169    1.0319    2.1320   -0.0983    0.1123
    % -6.2500   -4.5243    2.3261   -1.2496    2.0000   -0.2959    0.3895   -0.0824
    % -0.2737    1.1251   -2.4865    1.1016    1.1876   -1.8792    1.1803   -0.3821
    % -1.2465    1.2015    0.3750   -0.1294    0.4387   -2.3145    0.7589    0.4292
    %  0.6502    0.6545   -0.9012   -0.9573   -1.9742    0.9304    0.3205    0.2095
end
