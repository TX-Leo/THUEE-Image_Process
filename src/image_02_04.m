my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');
    % 取 hall_gray 进行验证
    image = double(hall_gray)-128;
    % 对DCT系数转置后，逆变换的图像
    image_transposition = my_get_inversed_image(image,[8,8],@my_dct2_transposition);
    % 对DCT系数旋转90°后，逆变换的图像
    image_rotate_90 = my_get_inversed_image(image,[8,8],@my_dct2_rotate_90);
    % 对DCT系数旋转180°后，逆变换的图像
    image_rotate_180 = my_get_inversed_image(image,[8,8],@my_dct2_rotate_180);
    % 画图并保存
    my_plot(hall_gray,image_transposition,image_rotate_90,image_rotate_180);
end
% 对DCT系数转置
function image_changed = my_dct2_transposition(image)
    image_changed = dct2(image)';
end
% 对DCT系数旋转90°
function image_changed = my_dct2_rotate_90(image)
    image_changed = rot90(dct2(image));
end
% 对DCT系数旋转180°
function image_changed = my_dct2_rotate_180(image)
    image_changed = rot90(dct2(image), 2);
end
% 将系数置零之后逆变换
function image_changed = my_get_inversed_image(image,matrix,func)
    image_changed = uint8(blockproc(blockproc(image, matrix, @(blk) func(blk.data)), [8, 8], @(blk) idct2(blk.data)) + 128);
end
% 画图
function my_plot(hall_gray,image_transposition,image_rotate_90,image_rotate_180)
    % origin image
    subplot(4, 1, 1);
    imshow(hall_gray);
    title('hall gray');
    % image after transposition
    subplot(4, 1, 2);
    imshow(image_transposition);
    title('image transposition');
    % image after rotate_90
    subplot(4, 1, 3);
    imshow(image_rotate_90);
    title('image rotate 90');
    % image after rotate_180
    subplot(4, 1, 4);
    imshow(image_rotate_180);
    title('image rotate 180');
    % save image
    imwrite(hall_gray, '../generated_photo/image_02_04_hall_gray.bmp');
    imwrite(image_transposition, '../generated_photo/image_02_04_image_transposition.bmp');
    imwrite(image_rotate_90, '../generated_photo/image_02_04_image_rotate_90.bmp');
    imwrite(image_rotate_180, '../generated_photo/image_02_04_image_rotate_180.bmp');
end