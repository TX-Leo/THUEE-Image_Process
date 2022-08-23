my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    load('../resource/hall.mat');
    circle = my_circle(hall_color)
    chess = my_chess(hall_color)
    % 画圆
    subplot(1, 2, 1);
    imshow(circle);
    title('circle');
    imwrite(circle, '../generated_photo/image_01_01_circle.bmp');
    % 涂成黑白格
    subplot(1, 2, 2);
    imshow(chess);
    title('chess');
    imwrite(chess, '../generated_photo/image_01_01_chess.bmp');
end
% 以测试图像的中心为圆心，将图像的长和宽中较小值的一半为半径画一个红颜色的圆；
function circle = my_circle(image_src)
    % get the height and width of photo
    [height, width, ~] = size(image_src);
    row = zeros([height, width]) + [1 : height]';
    col = zeros([height, width]) + [1 : width];
    circle = image_src;

    is_in_circle = ((row - (height+1)/2).^2 + (col - (width+1)/2).^2) <= min(height/2, width/2)^2 & ((row - (height+1)/2).^2 + (col - (width+1)/2).^2) > 0.95 * min(height/2, width/2)^2;
    % cat连接数组(logical转换为一个逻辑值数组)
    red_circle = cat(3, is_in_circle, logical(zeros(size(is_in_circle))), logical(zeros(size(is_in_circle))));
    greenblue_circle = cat(3, logical(zeros(size(is_in_circle))), is_in_circle, is_in_circle);
    circle(red_circle) = uint8(255);
    circle(greenblue_circle) = uint8(0);
    % subplot(1, 2, 1);
    % imshow(circle);
    % imwrite(circle, '../generated_photo/image_01_01_circle.bmp');
end
% 将测试图像涂成国际象棋状的“黑白格”的样子，其中“黑”即黑色，“白”则意味着保留原图。
function chess = my_chess(image_src)
    % get the height and width of photo
    [height, width, ~] = size(image_src);
    row = zeros([height, width]) + [1 : height]';
    col = zeros([height, width]) + [1 : width];
    chess = image_src;
    is_black = xor(mod(floor((row - 1) / 10), 2) == 0, mod(floor((col - 1) / 10), 2) == 1);
    % cat连接数组
    draw = cat(3, is_black, is_black, is_black);
    chess(draw) = 0;
    % subplot(1, 2, 2);
    % imshow(chess);
    % imwrite(chess, '../generated_photo/image_01_01_chess.bmp');
end
