function makeMany()

%Just for compiling lots of videos!
%Note that the exact Ken Burns path of each video is NOT guaranteed
%to repeat for a given (manner, path, agent) triplet.

%7/2/15, pilot movies for debugging the fMRI script.  These exported so
%oddly!!!!!!
%makeKenBurnsStims({'rotate','rock','sine','wheelie'},...
%    {'to','tofar','circle','onto'},...
%    {1,2,3,8},'movie', 0)

%makeKenBurnsStims({'halfrotate','bounce','vibrate','stopstart'},...
%    {'past','under','behind','underfar'},...
%    {5,4,7,6},'movie', 0)



%6/29/15, for the first MannerPath  fMRI experiment

makeKenBurnsStims({'rotate','rock','sine','wheelie'},...
    {'to','tofar','circle','onto'},...
    {2,1,3,8},'movie', 1, 1) %the final 1s set KB yes, motion bar yes

makeKenBurnsStims({'halfrotate','bounce','vibrate','stopstart'},...
    {'past','under','behind','underfar'},...
    {5,4,7,6},'movie', 1, 1)

% %Checking motion bar placement
% 
% makeKenBurnsStims({'halfrotate','bounce'},...
%      {'behind','underfar'},...
%      {'5','4'},'movie', 1, 1)