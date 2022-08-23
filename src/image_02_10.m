my_main()
% 主函数5
function my_main()
    clear all;
    close all;
    clc;
    load('../generated_photo/jpegcodes.mat');
    % input
    input_length = 120 * 168; % 原图像为 120*168 的灰度图
    % output
    ouput_length = (length(dc_stream) + length(ac_stream)) / 8 ; % DC 码流长度为 2031 比特，AC 码流长度为 23072 比特
    % compression ratio
    disp(input_length / ouput_length);  %6.4247
end
