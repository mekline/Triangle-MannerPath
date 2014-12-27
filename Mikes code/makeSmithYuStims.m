bkg = 255; % background gray
lens = 60;
f = 300;
currentFolder = pwd;

funcs.f1 = @(x) sin(x);
funcs.f2 = @(x) cos(x.*2);
funcs.f3 = @(x) sin(x.*2);
funcs.f4 = @(x) cos(x);

f_order = [1 2; 3 1; 2 3; 4 1; 2 4; 3 4];

for obj = 1:1
  baseimg = imread([currentFolder '/img/' num2str(obj) '.jpg'],'JPEG');
  baseimg = imresize(baseimg,.5);
  [m n p] = size(baseimg);
  img = uint8(ones(m+2*f,n+2*f,p))*255;
  img(f+1:f+m,f+1:f+n,:) = baseimg;
  
  xs = 0:2*pi / lens:2*pi;
  ys = 0:2*pi / lens:2*pi;
  
  x = round(eval(['funcs.f' num2str(f_order(obj,1)) '(xs)']))*7;
  y = round(eval(['funcs.f' num2str(f_order(obj,2)) '(ys)']))*7;

  clear m;
  for i = 1:lens
    image(img);
    axis off;
    drawnow;
    img = moveImg(img,x(i),y(i),bkg);
    m(i) = getframe;
  end

  movie2avi(m,[num2str(obj) '.avi'],'FPS',30);
end