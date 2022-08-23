function info = info_find(find_way,In)
    load('../resource/JpegCoeff.mat');% DCTAB, ACTAB, QTAB
    if find_way ==1
        info = my_find1(In);    
    elseif find_way ==2
        info = my_find2(In,QTAB);
    elseif find_way ==3
        info = my_find3(In);
    end
end
% 第一种寻找方法
function info = my_find1(In)
    info = uint8(bitget(int64(round(In)), 1));
end
% 第二种寻找方法
function info = my_find2(In, QTAB)
    [~, min_idx] = min(my_zigzag_scan(QTAB));
    info = uint8(bitget(int64(round(In(min_idx, :))), 1));
end
% 第三种寻找方法
function info = my_find3(In)
    info = uint8(zeros([1, size(In, 2)]));
    for i = 1 : 1 : size(In, 2)
        this_seq = flipud(In(:, i));
        if this_seq == 0
            info(i) = 0;    % error
            disp('Warning: Get message error: All is zero!');
        else
            is_zero = this_seq ~= 0;
            [~, idx] = max(is_zero);
            if this_seq(idx) == 1
                info(i) = 1;
            elseif this_seq(idx) == -1
                info(i) = 0;
            else
                info(i) = 0;    % error
                disp('Warning: Get message error: Not 1 or -1!');
            end
        end
    end
end

% 正zigzag
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