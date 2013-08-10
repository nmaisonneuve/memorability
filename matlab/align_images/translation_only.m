ima = imread('im1.jpg');
imb = imread('im2.jpg');

f1 = figure(1);
f2 = figure(2);

%subfig(2,1,1,f1); imagesc(ima);
%subfig(2,1,2,f2); imagesc(imb);

subplot(2,1,1); 
f1 = subimage(ima); %imagesc(ima);
subplot(2,1,2), 

f2 = subimage(imb); %imagesc(imb);

axes(f1);
%figure(f1);
xa = ginput(1);

figure(f2);
xb = ginput(1);


x1a = xa(1,:)';
%x2a = xa(2,:)';

x1b = xb(1,:)';
%x2b = xb(2,:)';

%t = (x1a + x2a)/2  - (x1b + x2b)/2; 
t = -x1b + x1a; 


la = sqrt((x1a-x2a)'*(x1a-x2a));
lb = sqrt((x1b-x2b)'*(x1b-x2b));
sc = la / lb;

Hbtoa = [1 0 t(1,1);0 1 t(2,1); 0 0 1];


bbox = [-200 7000 -200 3500] % image space for mosaic
%bbox = [-400 1200 -200 700] % image space for mosaic
imaw = vgg_warp_H(ima, eye(3),'linear', bbox); % warp image 1 to mosaic image
imbw = vgg_warp_H(imb, Hbtoa, 'linear', bbox);


figure(3); clf;
imagesc(imaw);

figure(4); clf;
imagesc(imbw);




% Hbtoa = maketform('affine',[1 0 t(1,1);0 1 t(2,1); 0 0 1]');
% transformed_imb = imtransform(imb,Hbtoa);
% figure(3), imshow(imb), 
% figure(4), imshow(transformed_imb)





