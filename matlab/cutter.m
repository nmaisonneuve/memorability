source ./matlab/iminterpnn.m

%%
%% Transform panoramic images into perspective image
%%
%% inputpath: path of the panoramic image
%% outputpath: path of the output cutted image
%% _hfov: horizontal filled of view [in degree]
%% _yaw: horizontal angle (0=front side , 180=back side, 90=left side, 270=right side)
%% _pitch : vertical angle (0 =bottom , 180 = sky)
%% _axial: rotat

function cutout(input_path, output_path, _yaw = 0, _hfov = 60, _pitch = 0)

	printf("input_path: %s" , input_path);
	printf("output_path: %s" , output_path);
	printf("side angle: %i" , _yaw);

	%% Perspective view parameters
	iimh = 3328;  iimw=6656;      % input  image size
	oimh =  537;   oimw = 936;       % output image size

	%% TRANSFORMATION CONFIGURATION
	% horizontal filled of view [rad]
	hfov = _hfov * (pi/180);
	f = oimw/(2*tan(hfov/2)); % focal length [pix]

	%% horizontal angle (0=front side , 180=back side, 90=left side, -90=right side)
	yaw = _yaw * (2 * pi)/360.0;

	%% vertical angle
	pitch = _pitch * (pi/180);

	%% axial angle (required if steep street)
	pitch_2 = 0;

	printf("parameters: focal length %f\npitch: %f\nhfov: %f\n,yaw: %f\n",f,pitch, hfov, yaw)

	ouc = (oimw+1)/2;
	ovc = (oimh+1)/2;             % output image center
	iuc = (iimw+1)/2;
	ivc = (iimh+1)/2;             % input image center
	sw=iimw/ (2 * pi);
	sh=iimh/ pi;

	%% Tangent plane to unit sphere mapping
	[X Y] = meshgrid(1:oimw, 1:oimh);
	    X = X-ouc;   Y = Y-ovc;             % shift origin to the image center
	    Z = f+0*X;
	PTS = [X(:)'; Y(:)'; Z(:)'];

	% Transformation for oitch angle
	  Tx = expm([0     -pitch_2/180*pi           0        ;...
	             pitch_2/180*pi       0       pitch/180*pi;
	             0 -pitch/180*pi   0]);

	% rotation w.r.t x-axis about pitch angle
	PTSt = Tx * PTS;
	Xt=reshape(PTSt(1,:),oimh, oimw);
	Yt=reshape(PTSt(2,:),oimh, oimw);
	Zt=reshape(PTSt(3,:),oimh, oimw);
	THETA = atan2(Xt, Zt);                 % cartesian to spherical
	PHI = atan(Yt./sqrt(Xt.^2+Zt.^2));
	%THETA = mod(THETA + yaw,2 * pi);
	THETA = THETA + yaw;


	U = sw * THETA+iuc;
	V = sh * PHI  +ivc;
	img = imread(input_path);
	imwrite(iminterpnn(img, U,V),output_path);
endfunction

arg_list = argv();
input_path = arg_list{1};
output_path = arg_list{2};
side_angle =  str2num(arg_list{3})

cutout(input_path, output_path, side_angle);