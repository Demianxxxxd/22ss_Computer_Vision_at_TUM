function varargout = GUI(varargin)


% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 15-Jul-2022 21:16:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled1_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled1_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function untitled1_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled1 (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled1_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
cv=main;
im = handles.im;
[vx,vy,irx,iry,orx,ory] = cv.TIP_GUI(im);
[bim,bim_alpha,vx,vy,ceilrx,ceilry,floorrx,floorry,...
    leftrx,leftry,rightrx,rightry,backrx,backry] = ...
    cv.TIP_get5rects(im,vx,vy,irx,iry,orx,ory);

% display the expended image
figure(2);
imshow(bim);
alpha(bim_alpha);

% Draw the vanishing Point and the 4 faces 
figure(2);
hold on;
plot(vx,vy,'w*');
plot([ceilrx ceilrx(1)], [ceilry ceilry(1)], 'y-');
plot([floorrx floorrx(1)], [floorry floorry(1)], 'm-');
plot([leftrx leftrx(1)], [leftry leftry(1)], 'c-');
plot([rightrx rightrx(1)], [rightry rightry(1)], 'g-');
hold off;

% fronto-parallel views,each plane

xmin = min([ceilrx(1) floorrx(4) leftrx(1)]);
xmax = max([ceilrx(2) floorrx(3) rightrx(3)]);
ymin = min([leftry(1) rightry(2) ceilry(1)]);
ymax = max([leftry(4) rightry(3) floorry(3)]);

destn = [xmin xmax xmax xmin; ymin ymin ymax ymax];

% 3D dimension
sim_trig_ratio = sqrt((xmax-xmin)*(ymax-ymin)/((backrx(2)-backrx(1))*(backry(3)-backry(2))));
focal_length = max(backrx(2)-backrx(2),backry(3)-backry(2))/2/tan(pi/180*30/2);
depth = focal_length*(sim_trig_ratio-1);

% transform
source_ceil = [ceilrx; ceilry];
[~,t_ceil] = cv.computeH(source_ceil, destn);
ceil = imtransform(bim, t_ceil, 'xData',[xmin xmax],'yData',[ymin ymax]);
%figure(3); imshow(ceil); axis image;

source_floor = [floorrx; floorry];
[~,t_floor] = cv.computeH(source_floor, destn);
floor = imtransform(bim, t_floor, 'xData',[xmin xmax],'yData',[ymin ymax]);
%figure(4); imshow(floor); axis image;

source_back = [backrx; backry];
[~,t_back] = cv.computeH(source_back, destn);
back = imtransform(bim, t_back, 'xData',[xmin xmax],'yData',[ymin ymax]);
% alpha_b = ones(size(back,1),size(back,2));
%figure(5); imshow(back); axis image;

source_left = [leftrx; leftry];
[~,t_left] = cv.computeH(source_left, destn);
left = imtransform(bim, t_left, 'xData',[xmin xmax],'yData',[ymin ymax]);
%figure(6); imshow(left); axis image;

source_right = [rightrx; rightry];
[~,t_right] = cv.computeH(source_right, destn);
right = imtransform(bim, t_right, 'xData',[xmin xmax],'yData',[ymin ymax]);
%figure(7); imshow(right); axis image;

ceil_planex = [0 0 0; depth depth depth];
ceil_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
ceil_planez = [ymax ymax ymax; ymax ymax ymax];

floor_planex = [depth depth depth; 0 0 0];
floor_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
floor_planez = [ymin ymin ymin; ymin ymin ymin];

back_planex = [depth depth depth; depth depth depth];
back_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
back_planez = [ymax ymax ymax; ymin ymin ymin];

left_planex = [0 depth/2 depth; 0 depth/2 depth];
left_planey = [xmin xmin xmin; xmin xmin xmin];
left_planez = [ymax ymax ymax; ymin ymin ymin];

right_planex = [depth depth/2 0; depth depth/2 0];
right_planey = [xmax xmax xmax; xmax xmax xmax];
right_planez = [ymax ymax ymax; ymin ymin ymin];

% create the surface and texturemap 
view = figure(8);
set(view,'windowkeypressfcn','set(gcbf,''Userdata'',get(gcbf,''CurrentCharacter''))') ;
set(view,'windowkeyreleasefcn','set(gcbf,''Userdata'','''')') ;
set(view,'Color','black')
hold on
warp(ceil_planex,ceil_planey,ceil_planez,ceil);
warp(floor_planex,floor_planey,floor_planez,floor);
warp(back_planex,back_planey,back_planez,back);
warp(left_planex,left_planey,left_planez,left);
warp(right_planex,right_planey,right_planez,right);

axis equal;  % make X,Y,Z dimentions be equal
axis vis3d;  % freeze the scale for better rotations
axis off;    % turn off the stupid tick marks
camproj('perspective');  % make it a perspective projection

% camera position
camx = -2300;
camy = 1312;
camz = 858.8;

% camera target
% tarx = 228.5;
% tary = 1312;
% %tarz = 817.5;
% tarz = 858.8;

% camera step
stepx = 0.2;stepy = 0.2;stepz = 0.2;
handles.stepx=stepx;
handles.stepy=stepy;
handles.stepz=stepz;
guidata(hObject, handles)

camup([0,0,1]);
campos([camx camy camz]);

% hObject    handle to pushbutton1 (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(~, ~, handles)
figure(8)
% stepx = handles.stepx;
stepy = handles.stepy;
% stepz = handles.stepz;
camdolly(0,stepy,0,'fixtarget');

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(~, ~, handles)
figure(8)
% stepx = handles.stepx;
stepy = handles.stepy;
% stepz = handles.stepz;
camdolly(0,-stepy,0,'fixtarget');
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(~, ~, handles)
figure(8)
stepx = handles.stepx;
% stepy = handles.stepy;
% stepz = handles.stepz;
camdolly(-stepx,0,0,'fixtarget');



% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(~, ~, handles)
figure(8)
stepx = handles.stepx;
% stepy = handles.stepy;
% stepz = handles.stepz;
camdolly(stepx,0,0,'fixtarget');

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(~, ~, handles)
figure(8)
% stepx = handles.stepx;
% stepy = handles.stepy;
stepz = handles.stepz;
%camdolly(0,stepy,0,'fixtarget');
camdolly(0,0,stepz,'fixtarget');
% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(~, ~, handles)
figure(8)
% stepx = handles.stepx;
% stepy = handles.stepy;
stepz = handles.stepz;
%camdolly(0,-stepy,0,'fixtarget');
camdolly(0,0,-stepz,'fixtarget');
% --- Executes on button press in pushbutton12.
%path
function pushbutton12_Callback(hObject, ~, handles)
[filename, filepath]=uigetfile({'*.bmp;*.jpg;*.png'},'choose the picture');
 
if isequal(filename,0) ||  isequal(filepath,0)
    errordlg('please choose again','wrong');
    return;
else
     set(handles.text2,'string',[filepath filename])
end

road=get(handles.text2,'String');
handles.road=road;
guidata(hObject, handles)




function edit1_Callback(~, ~, ~)


% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, ~, ~)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, ~, handles)
road=handles.road;
axes(handles.axes1);              %1 axes
imshow(road);
im = imread(road);
handles.im=im;
guidata(hObject, handles)

