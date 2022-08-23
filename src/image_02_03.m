my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');
    % 取 hall_gray 进行验证
    image = double(hall_gray)-128;
    % 将DCT系数矩阵中右侧四列的系数全部置零后，逆变换的图像
    image_clear_right = my_get_inversed_image(image,[8,8],@my_dct2_clear_right);
    % 将DCT系数矩阵中左侧四列的系数全部置零后，逆变换的图像
    image_clear_left = my_get_inversed_image(image,[8,8],@my_dct2_clear_left);
    % 画图并保存
    my_plot(hall_gray,image_clear_right,image_clear_left);
end
% 将DCT系数矩阵中右侧四列的系数全部置零
function image_changed = my_dct2_clear_right(image)
    image_changed = dct2(image);
    image_changed(:, 5:8) = 0;
end
% 将DCT系数矩阵中左侧四列的系数全部置零
function image_changed = my_dct2_clear_left(image)
    image_changed = dct2(image);
    image_changed(:, 1:4) = 0;
end
% 逆变换
function image_changed = my_get_inversed_image(image,matrix,func)
    image_changed = uint8(blockproc(blockproc(image, matrix, @(blk) func(blk.data)), [8, 8], @(blk) idct2(blk.data)) + 128);
end
% 画图
function my_plot(hall_gray,image_clear_right,image_clear_left)
    % origin image
    subplot(3, 1, 1);
    imshow(hall_gray);
    title('hall gray');
    % image after clearing right
    subplot(3, 1, 2);
    imshow(image_clear_right);
    title('image clear right');
    % image after clearing left
    subplot(3, 1, 3);
    imshow(image_clear_left);
    title('image clear left');
    % save image
    imwrite(hall_gray, '../generated_photo/image_02_03_hall_gray.bmp');
    imwrite(image_clear_right, '../generated_photo/image_02_03_image_clear_right.bmp');
    imwrite(image_clear_left, '../generated_photo/image_02_03_image_clear_left.bmp');
end