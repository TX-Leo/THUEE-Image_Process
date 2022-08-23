my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    % 训练人脸标准 L=3
    L = 3;
    standards = train_face_standard(L);
    subplot(3, 1, 1);
    plot([0 : 1 : 2^(3 * L) - 1], standards);
    title('train face standard L=3');
    % 训练人脸标准 L=4
    L = 4;  
    standards = train_face_standard(L);
    subplot(3, 1, 2);
    plot([0 : 1 : 2^(3 * L) - 1], standards);
    title('train face standard L=4');
    % 训练人脸标准 L=5
    L = 5;
    standards = train_face_standard(L);
    subplot(3, 1, 3);
    plot([0 : 1 : 2^(3 * L) - 1], standards);
    title('train face standard L=5');
end
% 训练人脸标准，训练集一共有33张照片，训练结果为standards
function standards = train_face_standard(L)
    img_num = 33;
    standards = zeros([1, 2^(3 * L)]);
    count = 0;
    for i = 1 : 1 : img_num
        image = imread(char("../resource/Faces/" + string(i) + ".bmp"));

        [height, width, ~] = size(image);
        image = reshape(image, height * width, 3);
        standard = zeros([1, 2^(3 * L)]);
        for j = 1 : 1 : height * width
            % RGB 的三个值拼合成一个值
             r = floor(double(image(j, 1)) * 2^(L - 8));
             g = floor(double(image(j, 2)) * 2^(L - 8));
             b = floor(double(image(j, 3)) * 2^(L - 8));
             val = r * 2^(2 * L) + g * 2^(L) + b;

             standard(val + 1) = standard(val + 1) + 1;
        end
        standard = standard / (height * width);

        standards = standards + standard;
        count = count + 1;
    end
    standards = standards / count;
end

