lens = 120; %Number of (motion) frames, here set to 4 sec.
currentFolder = pwd;

%Important points in the image (start, 'above', etc.); coded by top lh corner
points = [300 50;
    300, 200; 
    300 250; 
    300 450; 
    300 650; 
    300 700; 
    0 450; 
    100 450; 
    250 450;
    300 450];

%Let's get a (simple) path to animate!
startpos = points(1,:);
endpos = points(8,:);

x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);%length = lens!

%Here's a bunch more options for xy
%x = ones(lens,1)*200;
%y = ones(lens,1)*200;
%xs = 0:2*pi / lens:2*pi;
%ys = 0:2*pi / lens:2*pi; 
%x = xs*100;
%y = ys*50;
%x = points(:,1);
%y = points(:,2);
%x = round(eval(['funcs.f' num2str(f_order(obj,1)) '(xs)']))*7; %Get the x and y positions corresponding to the weird function!
%y = round(eval(['funcs.f' num2str(f_order(obj,2)) '(ys)']))*7;
    

%Because of how imrotate works, the size of img is not guaranteed!  
%(it adds buffer cells if needed to fit the whole img). But
%the midpoint is guaranteed to stay the midpoint!  So let's plot that
%instead.

x_midpoint = x+50;
y_midpoint = y+50;

for obj = 1:1
    img = imread([currentFolder '/img/' num2str(obj) '.jpg'],'JPEG'); %read in object
    [m n p] = size(img); %how big is it? (h, w, layers)
    
    backimg = imread([currentFolder '/img/bg_refgrid.jpg'],'JPEG'); %read in bg
    [q r s] = size(backimg);
    

    %Draw them to obj m
    clear m;
    
    %Draw one boring second of the triangle sitting in initial position!
    newimg = moveImg(img, backimg, x_midpoint(1)-50, y_midpoint(1)-50);
    for j=1:30
        m(j) = getframe;
        image(newimg);
        axis off;
        drawnow;
    end
    
    %Draw the animation
    for i = 1:lens
        img_rot = imrotate(img, (i-1)*(-360*3/(lens-1))); %the index adjustments mean we start and end with a full rotation!
        %how big is the img right now?
        [t u v] = size(img_rot);
        newimg = moveImg(img_rot, backimg, x_midpoint(i) - round(t/2),y_midpoint(i)-round(u/2));
        m(i+30) = getframe;
        image(newimg);
        axis off;
        drawnow;
    end
    
    %Draw two boring seconds of the final position
    for k = 1:60
        m(k+lens+30) = getframe;
        image(newimg);
        axis off;
        drawnow;
    end
  
%     %And here's something else for debugging - instead of redrawing the
%     %triangle, trace its path (this won't give us rotation, but that's
%     %relatively easy...leave it in to catch any weird rounding of the centerpoint!)
%     newimg = backimg;
%     for i = 1:lens
%         img_rot = imrotate(img, (i-1)*(-360*3/(lens-1)));
%         %how big is the img right now?
%         [t u v] = size(img_rot);
%         newimg = traceImg(img_rot, newimg, x_midpoint(i) - round(t/2),y_midpoint(i)-round(u/2));
%         %Note newimg input so we just keep adding...
%         m(i) = getframe;
%         image(newimg);
%         axis off;
%         drawnow;
%     end
  
 

  %Convert m to a movie :)
  movie2avi(m,[num2str(obj) '.avi'],'FPS',30);
end