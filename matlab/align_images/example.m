ima = imread('im2_before.jpg');
imb = imread('im2_after.jpg');

% display each image
f1=figure(1); clf;
axis image;
imagesc(ima);

f2=figure(2); clf;
axis image;
imagesc(imb);

% ask to the user to click on 3 landmarks in the image a
figure(f1);
points_a = ginput(3);

% and to click on the same 3 landmarks in the image b
figure(f2);
points_b = ginput(3);

% define parameters to get a box  canvas the sams size as image a
XData=[1 size(ima,2)];
YData=[1 size(ima,1)];

% find the best affine transformation
tform = maketform('affine',points_a, points_b);

% transform
I2 = imtransform(ima,tform,'XData',XData,'YData',YData);

% save
imwrite(I2, 'im2_before_aligned.jpg');
