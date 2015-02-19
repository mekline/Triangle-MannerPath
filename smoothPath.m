function [smoothX, smoothY] = smoothPath(x,y)

%This takes a series of points describing a path, and tries to 
%spread them out evenly to maintain a constant velocity!

%Calculate average segment length

lens = length(x);

segments = zeros(lens-1,1);
for i=1:lens-1
    segments(i) = pdist([x(i) y(i);x(i+1) y(i+1)],'euclidean');
end

targetGap = mean(segments);

%Adjust the points!  To do this: walk along the path created by the points,
%until we find the two surrounding the target distance.  Drop the point
%down at the correct distance from start, along the resulting tangent.

smoothX = zeros(lens,1);
smoothY = zeros(lens,1);
smoothX(1) = x(1);
smoothY(1)= y(1);


for i=1:lens-1
    targetDistance = (i-1)*targetGap;
    %Find the points surrounding targetDistance along the path
    p = 1;
    path = 0;
    segLength = 0;
    keepGoing = 1;
    while keepGoing
        segLength = pdist([x(p) y(p);x(p+1) y(p+1)],'euclidean');
        newPath = path + segLength;
        if newPath > targetDistance
            keepGoing = 0;
        else
            path = newPath;
            p = p + 1;
        end
    end
    %p and p+1 are our brackets!
    d = targetDistance-path; 
    direction = [(x(p+1)-x(p))/segLength, (y(p+1)-y(p))/segLength];
    newpoint = [x(p) y(p)] + d*direction;
    
    smoothX(i) = newpoint(1);
    smoothY(i) = newpoint(2);
        
end

%and grab the last point!

smoothX(lens) = x(lens);
smoothY(lens) = y(lens);
        
