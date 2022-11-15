% --
% Creates an image using the (x, y, z) of the room, the position of the chair or
% seat in the auditorium and the location of the speaker.
%
% "pkg load image" in octave to enable loading the image package
%
% You will need to pass the dimension of the room, The location of the loud speaker
% and the location of the seat or chair in meters
%
% Example
% R = [10 20 12];
% S = [5 2 10];
% C = [9, 5, 2];
% C = [8.5, 5, 2];
%
% Output is a png file of size fix_size
% --
% Sunil Kopparapu | Mon Oct 17 23:05:11 IST 2022

function cnn_in = best_seat_image(R, S, C)

% define the color to use
my_red=my_blue=my_green = 1;

% say 1 cm is 1 pixel; to convert m into cm multiply by 100
m2pix = 100;

% fix the size of the input image
fix_size = [256 256];

% radius of the pixels around the location 
my_radius = 3;

printf("Room Dimension: %d %d %d (m)\n", R(1), R(2), R(3));

% check if the loud speaker is inside the room
if(S<R)
 printf("Speaker Position: %d %d %d (m)\n", S(1), S(2), S(3));
else
 printf("Speaker Position outside room\n");
 return;
endif

% check if the seat is inside the room
if(C<R)
 printf("Chair Position: %d %d %d (m)\n", C(1), C(2), C(3));
else
 printf("Chair Position outside room\n");
 return;
endif

% convert to pixels. If you use m2pix as 100 then each cm in the auditorium is
% a pixel
Rpix = R*m2pix; Cpix = C*m2pix; Spix = S*m2pix;

% Create the front, side and top view
% image size is different initialize with different values 
% hopefully the network will understand which is the Fv, Tv and Sv.
% 

% add a gray value to different views. We want to implictly let the ML know the 
% views!
Fv = zeros(Rpix(1), Rpix(3)) + 0.01;
Sv = zeros(Rpix(2), Rpix(3)) + 0.02;
Tv = zeros(Rpix(1), Rpix(2)) + 0.03;

% location of the chair plotted. While it is a pixel because of resizing a
% pixel might be digitally removed, so making it a little thick a radius or
% my_radius
Fv = draw_circle(Fv, Cpix(1), Cpix(3), my_radius, my_red);
Sv = draw_circle(Sv, Cpix(2), Cpix(3), my_radius, my_blue);
Tv = draw_circle(Tv, Cpix(1), Cpix(2), my_radius, my_green);

% location of the loud speaker plotted. 
% doubling the radius amd making the color different
% The ML will understand that this is different from the seat
%  
Fv = draw_circle(Fv, Spix(1), Spix(3), 2*my_radius, 0.5*my_red);
Sv = draw_circle(Sv, Spix(2), Spix(3), 2*my_radius, 0.5*my_blue);
Tv = draw_circle(Tv, Spix(1), Spix(2), 2*my_radius, 0.5*my_green);

% creating an image
Fv_image = gray2ind(Fv,256);
Sv_image = gray2ind(Sv,256);
Tv_image = gray2ind(Tv,256);

Fv_resize = imresize(Fv_image, fix_size);
Sv_resize = imresize(Sv_image, fix_size);
Tv_resize = imresize(Tv_image, fix_size);

cnn_in = cat(3, Fv_resize, Sv_resize, Tv_resize);

% --
% uncomment this to see the image representation
% --
% imshow(cnn_in); 
% ts =  sprintf("Speaker: (%d %d %d), Seat: (%d %d %d) in Room: (%d, %d %d)",S(1), % S(2), S(3), C(1), C(2), C(3),
%R(1), R(2), R(3));
% title(ts)

% Create the file name.
fs =  sprintf("Speaker_%.2f-%.2f-%.2f_Seat_%.2f-%.2f-%.2f_Room_%.2f-%.2f-%.2f.png",S(1), S(2), S(3), C(1), C(2), C(3), R(1), R(2), R(3));

% create an RGB image
imwrite(cnn_in, fs)

printf("Created file: %s\n", fs);

endfunction

% function to plot a circle around x0, y0 with a radius r
% am sure there is a better way of implementing this.
%
function mod_mat = draw_circle(mat, x0,y0,r, value)

mod_mat = mat;

for x = x0-r:x0+r
 for y = y0-r:y0+r
  mod_mat(x,y) = value;
end
end

endfunction

