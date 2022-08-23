my_main()
% 主函数
function my_main()
    clear all;
    close all;
    clc;
    % y(n)= x(n - 1) - x(n)
    x = [1];
    y = [-1, 1];
    my_plot(x,y);
end
function my_plot(x,y)
    figure(1);
    title('零极点图');
    % zplane - Zero-pole plot for discrete-time systems
    zplane(y, x);
    
    figure(2);
    title('频响图');
    % freqz - Frequency response of digital filter
    freqz(y, x);
end