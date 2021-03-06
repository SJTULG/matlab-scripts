function [m1, m2, uOp, varargout] = cornerPoint(pointCloud, varargin)
% 
% 
%  [m1, m2, uOp, filtNtg] = cornerPoint(pointCloud)
%           [m1, m2, uOp] = cornerPoint(pointCloud, lb, up)
%           [m1, m2, uOp] = cornerPoint(pointCloud)
%
%
%     c1 = uOp(1); c2 = uOp(2);
%     n1 = uOp(3); n2 = uOp(4);
%    
%     xc = (-n1*c1 + n2*c2);
%     yc = (-n2*c1 -n1*c2);
%         
%     angle = ones(1,4)*atan2(n2,n1) + [0 1 2 3]*pi/2;
%

Ntg = sortrows(pointCloud,3);

if length(varargin) == 2 && varargin{1} > 0 && varargin{2} > 0    
    % Remove tailing points
    lb = varargin{1};
    ub = varargin{2};    
    
    N1 = round(length(Ntg)*lb); % 0.15
    N2 = round(length(Ntg)*ub); % 0.4

    sortNtg = Ntg(N1:end-N2,1:2);
    
    % Remove tailing points
    if nargout == 4
        varargout(1) = {Ntg(N1:end-N2,1:3)};
    end
else
    sortNtg = Ntg(:,1:2);
    
    % Remove tailing points
    if nargout == 4
        varargout(1) = {sortNtg};
    end
end


%% Find clockwise ordering for points

% Get the geometric center point of the pointCloud
m = mean(sortNtg);
% Define perpendicular line
perpLine = [1 -m(1)/m(2)]./norm([1 -m(1)/m(2)],2);

% project points onto perp line, using the formula proj_s-on-v =
% s*dot(v,s) since s is unitvector 

[r,c ] = size(sortNtg);

scalingFactor = sum(sortNtg .* repmat(perpLine,r,1),2); 
projPoints = repmat(scalingFactor,1,c) .* repmat(perpLine,r,1);
%
% Get angle for PC1 & PC2
x = [0 1];
phi = acos(sum(perpLine.*x)/(norm(x,2)*norm(perpLine,2)));
% Rotate PC1 points by phi
R = [cos(phi) -sin(phi); sin(phi) cos(phi)];

projPointsRotated = projPoints*R';

% Add Index before sorting them

projPointsRotated = [projPointsRotated, [1:length(projPointsRotated)]'];

sortedProjPointsRotated = sortrows(projPointsRotated,2);

% idxV represents the mapping from sorted to unsorted points
idxV = sortedProjPointsRotated(:,3);

orderedNtg = sortNtg(idxV,:);

%% Calculate L-shape
uOp = ISED(orderedNtg);

c1 = uOp(1);
c2 = uOp(2);
n1 = uOp(3);
n2 = uOp(4);

xc = (-n1*c1 + n2*c2);
yc = (-n2*c1 -n1*c2);

% Define each vector & normalize it 

% Todo
% Margin for which points to project 
%
V1 = [1 -n1/n2];
V2 = [1 n2/n1];
V1 = V1/norm(V1,2);
V2 = V2/norm(V2,2);

% project points onto line, using the formula proj_s-on-v =
% s*dot(v,s)/dot(s,s)
V = {V1 V2};
projPoints = cell(1,2);
projC = cell(1,2);

% Project points 
[r,c ] = size(orderedNtg);

for k = 1:length(V)
    top = sum(orderedNtg .* repmat(V{k},r,1),2);    

    scalingFactor = top;
    projPoints{k} = repmat(scalingFactor,1,c) .* repmat(V{k},r,1);
    % Do the same for (xc,yc)
    top = sum([xc yc] .* V{k});
    scalingFactor = top;
    projC{k} = scalingFactor.* V{k};
end

% Look at length on each projected line 

phi1 = acos(dot(V1, [0 1])); % Get rotation angle 
phi2 = acos(dot(V2, [0 1]));

R1 = [cos(phi1) -sin(phi1); sin(phi1) cos(phi1)];
R2 = [cos(phi2) -sin(phi2); sin(phi2) cos(phi2)];

projPointsR1 = projPoints{1}*R1'; % Apply rotation 
projPointsR2 = projPoints{2}*R2';

projPointsR1 = projPointsR1(:,2);% Keep second column
projPointsR2 = projPointsR2(:,2); 

% Remove outliers
% TODO - Make this better, only works for one point, and not an enitre
% cluster. 

projPointsR1 = sort(projPointsR1);
diffR1 = [0; diff(projPointsR1)];
i1 = abs(diffR1) > 1; % A point separated more than 1 meter from its nearest neighbor is excluded 
projPointsR1(i1) = [];

projPointsR2 = sort(projPointsR2);
diffR2 = [0; diff(projPointsR2)];
i2 = abs(diffR2) > 1;
projPointsR2(i2) = [];

% These are used for diagnostics 
% [i2 diffR2 projPointsR2]  
% plot(ones(1,length(projPointsR2)), projPointsR2, 'x') 

projPointsR1 = projPointsR1 - min(projPointsR1); % Set measure from zero 
projPointsR2 = projPointsR2 - min(projPointsR2);

[m1, idx1] = max(projPointsR1);
[m2, idx2] = max(projPointsR2);


end