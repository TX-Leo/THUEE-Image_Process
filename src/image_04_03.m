my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    image_src = '../resource/test_faces/Bayern.jpg';
    image = imread(image_src);
    subplot(3,2,1);
    imshow(image);
    title('original image');

    image_src = '../resource/test_faces/Bayern.jpg';
    image = imread(image_src);
    L = 4;%3 4 5 6 7
    threshold_value = 0.73;
    rectangle_step_size = [3 ,3];
    rectangle_size = [15, 15];
    imwrite(image,'../resource/test_faces/Bayern_normal.jpg');
    image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size);
    subplot(3,2,2);
    imshow(image);
    title('the result after face recognition (normal)');

    image_src = '../resource/test_faces/Bayern.jpg';
    image = imread(image_src);
    L = 4;%3 4 5 6 7
    threshold_value = 0.73;
    rectangle_step_size = [3 ,3];
    rectangle_size = [15, 15];
    image = rot90(image, 3);
    imwrite(image,'../resource/test_faces/Bayern_rot90.jpg');
    image_src = '../resource/test_faces/Bayern_rot90.jpg';
    image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size);
    subplot(3,2,3);
    imshow(image);
    title('the result after face recognition (rotate 90)');

    image_src = '../resource/test_faces/Bayern.jpg';
    image = imread(image_src);
    L = 4;%3 4 5 6 7
    threshold_value = 0.73;
    rectangle_step_size = [3 ,3];
    rectangle_size = [15, 15];
    [a,b] = size(image);
    image = imresize(image,[a 2*b]);
    imwrite(image,'../resource/test_faces/Bayern_widen.jpg');
    image_src = '../resource/test_faces/Bayern_widen.jpg';
    image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size);
    subplot(3,2,4);
    imshow(image);
    title('the result after face recognition (widen)');
    
    image_src = '../resource/test_faces/Bayern.jpg';
    image = imread(image_src);
    L = 4;%3 4 5 6 7
    threshold_value = 0.73;
    rectangle_step_size = [3 ,3];
    rectangle_size = [15, 15];
    BrightFactor = 1.5; %可以通过改变亮度因子来改变图片亮度
    image = rgb2hsv( image ); %图片的颜色空间转换 
    image( : , : , 3 ) = image( : , : , 3 ) * BrightFactor;
    image = hsv2rgb( image ); % hsv => rgb 
    imwrite(image,'../resource/test_faces/Bayern_brighten.jpg');
    image_src = '../resource/test_faces/Bayern_brighten.jpg';
    image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size);
    subplot(3,2,5);
    imshow(image);
    title('the result after face recognition (brighten)');

    image_src = '../resource/test_faces/Bayern.jpg';
    image = imread(image_src);
    L = 4;%3 4 5 6 7
    threshold_value = 0.73;
    rectangle_step_size = [3 ,3];
    rectangle_size = [15, 15];
    BrightFactor = 0.75; %可以通过改变亮度因子来改变图片亮度
    image = rgb2hsv( image ); %图片的颜色空间转换 
    image( : , : , 3 ) = image( : , : , 3 ) * BrightFactor;
    image = hsv2rgb( image ); % hsv => rgb 
    imwrite(image,'../resource/test_faces/Bayern_darken.jpg');
    image_src = '../resource/test_faces/Bayern_darken.jpg';
    image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size);
    subplot(3,2,6);
    imshow(image);
    title('the result after face recognition (darken)');

end


function image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size)
    image = imread(image_src);
    standards = train_face_standard(L);
    image = check_face(image, standards, L, threshold_value, rectangle_step_size, rectangle_size);
end
% 人脸识别（圈出来）
function img_res = check_face(img, properties, L, threshold_value, rectangle_step_size, rectangle_size)
    [h w ~] = size(img);
    h_strike = rectangle_step_size(1);
    w_strike = rectangle_step_size(2);
    h_test = rectangle_size(1);
    w_test = rectangle_size(2);
    h_num = floor((h - h_test) / h_strike + 1);
    w_num = floor((w - w_test) / w_strike + 1);
    total_num = h_num * w_num;
    find_top = [];
    find_left = [];
    find_bottom = [];
    find_right = [];
    errs = [];
    find_cnt = 0;
    for i = 1 : h_strike : h - h_test + 1
        for j = 1 : w_strike : w - w_test + 1
            test_img = img(i : i + h_test - 1, j : j + w_test - 1, :);
            this_prop = get_property(test_img, L);
            err = 1 - sum(sqrt(this_prop) .* sqrt(properties));
            if err < threshold_value
                find_cnt = find_cnt + 1;
                find_top(find_cnt) = i;
                find_bottom(find_cnt) = i + h_test - 1;
                find_left(find_cnt) = j;
                find_right(find_cnt) = j + w_test - 1;
            end
        end
    end
    illegal_mat = logical(zeros([h w]));
    row_idxs = zeros([h, w]) + [1 : h]';
    col_idxs = zeros([h, w]) + [1 : w];
    for i = 1 : 1 : find_cnt
        this_mat = (row_idxs >= find_top(i) & row_idxs <= find_bottom(i)) ...
                 & (col_idxs >= find_left(i) & col_idxs <= find_right(i));
        illegal_mat = this_mat | illegal_mat;
    end
    [labs, n] = bwlabel(illegal_mat);
    min_left = zeros(n, 1) + w;
    min_top = zeros(n, 1) + h;
    max_right = zeros(n, 1);
    max_bottom = zeros(n, 1);
    for i = 1 : 1 : find_cnt
        lab = labs(find_top(i), find_left(i));
        min_left(lab) = min(min_left(lab), find_left(i));
        min_top(lab) = min(min_top(lab), find_top(i));
        max_right(lab) = max(max_right(lab), find_right(i));
        max_bottom(lab) = max(max_bottom(lab), find_bottom(i));
    end
    edge_weight = round(min(max(max_right - min_left), max(max_bottom - min_top)) * 0.05);
    draw_mat = logical(zeros(size(img)));
    for i = 1 : 1 : n
        draw_mat(min_top(i) : max_bottom(i), min_left(i) : min_left(i) + edge_weight) = true;
        draw_mat(min_top(i) : min_top(i) + edge_weight, min_left(i) : max_right(i)) = true;
        draw_mat(min_top(i) : max_bottom(i), max(1, max_right(i) - edge_weight) : max_right(i)) = true;
        draw_mat(max(1, max_bottom(i) - edge_weight) : max_bottom(i), min_left(i) : max_right(i)) = true;
    end
    draw_r = cat(3, draw_mat, logical(zeros(size(draw_mat))), logical(zeros(size(draw_mat))));
    img(draw_r) = uint8(255);
    img_res = img;
end
function property = get_property(img, L)
    [h, w, ~] = size(img);
    img = reshape(img, h * w, 3);
    property = zeros([1, 2^(3 * L)]);
    for j = 1 : 1 : h * w
        %  val = rgb2val(img(j, 1), img(j, 2), img(j, 3), L);
        % RGB 的三个值拼合成一个值
        r = floor(double(img(j, 1)) * 2^(L - 8));
        g = floor(double(img(j, 2)) * 2^(L - 8));
        b = floor(double(img(j, 3)) * 2^(L - 8));
        val = r * 2^(2 * L) + g * 2^(L) + b;
         property(val + 1) = property(val + 1) + 1;
    end
    property = property / (h * w);
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