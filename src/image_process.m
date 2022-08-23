function varargout = image_process(varargin)
% IMAGE_PROCESS MATLAB code for image_process.fig
%      IMAGE_PROCESS, by itself, creates a new IMAGE_PROCESS or raises the existing
%      singleton*.
%
%      H = IMAGE_PROCESS returns the handle to a new IMAGE_PROCESS or the handle to
%      the existing singleton*.
%
%      IMAGE_PROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_PROCESS.M with the given input arguments.
%
%      IMAGE_PROCESS('Property','Value',...) creates a new IMAGE_PROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_process_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_process_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image_process

% Last Modified by GUIDE v2.5 21-Aug-2022 21:03:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image_process_OpeningFcn, ...
                   'gui_OutputFcn',  @image_process_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before image_process is made visible.
function image_process_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_process (see VARARGIN)

% Choose default command line output for image_process
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes image_process wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = image_process_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_info_hide_01_add_picture.
function button_info_hide_01_add_picture_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_hide_01_add_picture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 添加照片
    [file,path,~] = uigetfile({'*.jpg';'*.bmp';'*.png'},'请选择要信息隐藏的图片'); % Open the file selection dialog box
    if isequal(file,0)
    disp('User selected Cancel');
    else
    disp(['User selected ', fullfile(path,file)]);
    end
    file_path = fullfile(path,file);
    image = imread(file_path);
    % 传输变量
    handles.info_hide_image_file_path = file_path;
    guidata(hObject, handles);
    % 显示图片
    axes(handles.axes_info_hide_before);
    imshow(image);
    title("info hide before");

% --- Executes on selection change in listbox_info_hide_01.
function listbox_info_hide_01_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_hide_01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_hide_01 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_hide_01


% --- Executes during object creation, after setting all properties.
function listbox_info_hide_01_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_hide_01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_info_find.
function listbox_info_find_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_find (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_find contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_find


% --- Executes during object creation, after setting all properties.
function listbox_info_find_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_find (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_info_hide_02_add_info.
function button_info_hide_02_add_info_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_hide_02_add_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 列表框输出信息（最多可以隐藏的信息大小）
    image_src = handles.info_hide_image_file_path;
    image = imread(image_src);
    [height,width] = size(image);
    output_string = ['你最多可以隐藏',string(height*width),'个0/1'];
    set(handles.listbox_info_hide_01, 'String', output_string);
    output_string = ['你最多可以隐藏',string(width),'个0/1'];
    set(handles.listbox_info_hide_02, 'String', output_string);
    set(handles.listbox_info_hide_03, 'String', output_string);
    
% --- Executes on button press in button_info_hide_03_start.
function button_info_hide_03_start_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_hide_03_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_info_hide_Callback(hObject, eventdata, handles)
% hObject    handle to edit_info_hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_info_hide as text
%        str2double(get(hObject,'String')) returns contents of edit_info_hide as a double


% --- Executes during object creation, after setting all properties.
function edit_info_hide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_info_hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_info_find_01_add_picture.
function button_info_find_01_add_picture_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_find_01_add_picture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 添加照片
    [file,path,~] = uigetfile({'*.jpg';'*.bmp';'*.png'},'请选择要识别的图片'); % Open the file selection dialog box
    if isequal(file,0)
    disp('User selected Cancel');
    else
    disp(['User selected ', fullfile(path,file)]);
    end
    file_path = fullfile(path,file);
    image = imread(file_path);
    % 传输变量
    handles.info_find_image_file_path = file_path;
    guidata(hObject, handles);
    % 显示图片
    axes(handles.axes_info_find_before);
    imshow(image);
    title("info find before");
% --- Executes on button press in button_info_find_03_start.
function button_info_find_03_start_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_find_03_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_face_recognition_01_add_picture.
function button_face_recognition_01_add_picture_Callback(hObject, eventdata, handles)
% hObject    handle to button_face_recognition_01_add_picture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 添加照片
    [file,path,~] = uigetfile({'*.jpg';'*.bmp';'*.png'},'请选择要识别的图片'); % Open the file selection dialog box
    if isequal(file,0)
    disp('User selected Cancel');
    else
    disp(['User selected ', fullfile(path,file)]);
    end
    file_path = fullfile(path,file);
    image = imread(file_path);
    % 传输变量
    handles.face_recognition_image_file_path = file_path;
    guidata(hObject, handles);
    % 显示图片
    axes(handles.axes_face_recognition_before);
    imshow(image);
    title("face recognition before");

% --- Executes on button press in button_face_recognition_02_input_parameters.
function button_face_recognition_02_input_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to button_face_recognition_02_input_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_face_recognition_03_start.
function button_face_recognition_03_start_Callback(hObject, eventdata, handles)
% hObject    handle to button_face_recognition_03_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    image_src = handles.face_recognition_image_file_path;
    L = str2num(get(handles.edit_face_recognition_L, 'String'));
    threshold_value = str2num(get(handles.edit_face_recognition_threshold_value, 'String'));
    rectangle_step_size = [str2num(get(handles.edit_face_recognition_rectangle_step_size_height, 'String')),str2num(get(handles.edit_face_recognition_rectangle_step_size_width, 'String'))];
    rectangle_size = [str2num(get(handles.edit_face_recognition_rectangle_size_height, 'String')),str2num(get(handles.edit_face_recognition_rectangle_size_width, 'String'))];
    image = face_recognition(image_src,L,threshold_value,rectangle_step_size,rectangle_size);
    % 显示图片
    axes(handles.axes_face_recognition_after);
    imshow(image);
    title("face recognition after");
    % save image
    imwrite(image, '../generated_photo/face_recognition_after.jpg');

function edit_face_recognition_L_Callback(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_face_recognition_L as text
%        str2double(get(hObject,'String')) returns contents of edit_face_recognition_L as a double


% --- Executes during object creation, after setting all properties.
function edit_face_recognition_L_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_face_recognition_threshold_value_Callback(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_threshold_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_face_recognition_threshold_value as text
%        str2double(get(hObject,'String')) returns contents of edit_face_recognition_threshold_value as a double


% --- Executes during object creation, after setting all properties.
function edit_face_recognition_threshold_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_threshold_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_face_recognition_rectangle_step_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_step_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_face_recognition_rectangle_step_size as text
%        str2double(get(hObject,'String')) returns contents of edit_face_recognition_rectangle_step_size as a double


% --- Executes during object creation, after setting all properties.
function edit_face_recognition_rectangle_step_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_step_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_face_recognition_rectangle_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_face_recognition_rectangle_size as text
%        str2double(get(hObject,'String')) returns contents of edit_face_recognition_rectangle_size as a double


% --- Executes during object creation, after setting all properties.
function edit_face_recognition_rectangle_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_face_recognition_rectangle_size_height_Callback(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_size_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_face_recognition_rectangle_size_height as text
%        str2double(get(hObject,'String')) returns contents of edit_face_recognition_rectangle_size_height as a double


% --- Executes during object creation, after setting all properties.
function edit_face_recognition_rectangle_size_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_size_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_face_recognition_rectangle_size_width_Callback(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_size_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_face_recognition_rectangle_size_width as text
%        str2double(get(hObject,'String')) returns contents of edit_face_recognition_rectangle_size_width as a double


% --- Executes during object creation, after setting all properties.
function edit_face_recognition_rectangle_size_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_face_recognition_rectangle_size_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_info_hide_03_start_way_01.
function button_info_hide_03_start_way_01_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_hide_03_start_way_01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    image_src =handles.info_hide_image_file_path ;
    info = get(handles.edit_info_hide, 'String');
    [image_res1,image_res2,image_res3,decoding_res1,decoding_res2,decoding_res3,info_matrix_height,info_matrix_width] =info_hide(image_src,info);
    % 显示图片
    axes(handles.axes_info_hide_after);
    imshow(image_res1);
    title("info hide after way 1");
    % save image
    imwrite(image_res1, '../generated_photo/info_hide_after_way_01.jpg');
    % 保存矩阵
    save('../generated_photo/decoding_res1.mat','decoding_res1','info_matrix_height','info_matrix_width');


% --- Executes on button press in button_info_hide_03_start_way_02.
function button_info_hide_03_start_way_02_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_hide_03_start_way_02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    image_src =handles.info_hide_image_file_path ;
    info = get(handles.edit_info_hide, 'String');
    [image_res1,image_res2,image_res3,decoding_res1,decoding_res2,decoding_res3,info_matrix_height,info_matrix_width] =info_hide(image_src,info);
    % 显示图片
    axes(handles.axes_info_hide_after);
    imshow(image_res2);
    title("info hide after way 2");
    % save image
    imwrite(image_res2, '../generated_photo/info_hide_after_way_02.jpg');
    % 保存矩阵
    save('../generated_photo/decoding_res2.mat','decoding_res2','info_matrix_height','info_matrix_width');

% --- Executes on button press in button_info_hide_03_start_way_03.
function button_info_hide_03_start_way_03_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_hide_03_start_way_03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    image_src =handles.info_hide_image_file_path ;
    info = get(handles.edit_info_hide, 'String');
    [image_res1,image_res2,image_res3,decoding_res1,decoding_res2,decoding_res3,info_matrix_height,info_matrix_width] =info_hide(image_src,info);
    % 显示图片
    axes(handles.axes_info_hide_after);
    imshow(image_res3);
    title("info hide after way 3");
    % save image
    imwrite(image_res3, '../generated_photo/info_hide_after_way_03.jpg');
    % 保存矩阵
    save('../generated_photo/decoding_res3.mat','decoding_res3','info_matrix_height','info_matrix_width');

% --- Executes on selection change in listbox_info_hide_02.
function listbox_info_hide_02_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_hide_02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_hide_02 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_hide_02


% --- Executes during object creation, after setting all properties.
function listbox_info_hide_02_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_hide_02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_info_hide_03.
function listbox_info_hide_03_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_hide_03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_hide_03 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_hide_03


% --- Executes during object creation, after setting all properties.
function listbox_info_hide_03_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_hide_03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_info_find_02_add_decode_matrix.
function button_info_find_02_add_decode_matrix_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_find_02_add_decode_matrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 添加矩阵
    [file,path,~] = uigetfile({'*.mat'},'请选择要识别的矩阵'); % Open the file selection dialog box
    if isequal(file,0)
    disp('User selected Cancel');
    else
    disp(['User selected ', fullfile(path,file)]);
    end
    file_path = fullfile(path,file);
    % 传输变量
    handles.info_find_mat_file_path = file_path;
    guidata(hObject, handles);
    % load(file_path);

% --- Executes on button press in button_info_find_03_start_way_01.
function button_info_find_03_start_way_01_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_find_03_start_way_01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    mat_src = handles.info_find_mat_file_path;
    struct = open(mat_src);
    decoding_res1 = struct.decoding_res1;
    % 寻找
    info = info_find(1,decoding_res1);
    % 解info
    info = info(1:struct.info_matrix_height,1:struct.info_matrix_width);
    info = info';
    disp('info_matrix:');
    disp(info);
    info = char(native2unicode(bi2de(info,'left-msb')))';
    % 列表框显示
    output_string = info;
    set(handles.listbox_info_find, 'String', output_string);

% --- Executes on button press in button_info_find_03_start_way_02.
function button_info_find_03_start_way_02_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_find_03_start_way_02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    mat_src = handles.info_find_mat_file_path;
    struct = open(mat_src);
    decoding_res2 = struct.decoding_res2;
    % 寻找
    info = info_find(2,decoding_res2);
    % 解info
    info = info(1,1:struct.info_matrix_height*struct.info_matrix_width);
    info = reshape(info,[struct.info_matrix_height,struct.info_matrix_width]);
    info = info';
    disp('info_matrix:');
    disp(info);
    info = char(native2unicode(bi2de(info,'left-msb')))';
    % 列表框显示
    output_string = info;
    set(handles.listbox_info_find, 'String', output_string);

% --- Executes on button press in button_info_find_03_start_way_03.
function button_info_find_03_start_way_03_Callback(hObject, eventdata, handles)
% hObject    handle to button_info_find_03_start_way_03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % 获得参数
    mat_src = handles.info_find_mat_file_path;
    struct = open(mat_src);
    decoding_res3 = struct.decoding_res3;
    % 寻找
    info = info_find(3,decoding_res3);
    % 解info
    info = info(1,1:struct.info_matrix_height*struct.info_matrix_width);
    info = reshape(info,[struct.info_matrix_height,struct.info_matrix_width]);
    info = info';
    disp('info_matrix:');
    disp(info);
    info = char(native2unicode(bi2de(info,'left-msb')))';
    % 列表框显示
    output_string = info;
    set(handles.listbox_info_find, 'String', output_string);
