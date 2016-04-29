%% clear all
clear all;
clc;

%% load geometrical data for static
pathWalls = 'static/kitti_crossing_static_walls.txt';
walls = kittiwalls2matlab(pathWalls);

%% test plot all walls and poles
figure;
hold on
for i = 1:size(walls,1)
    plotCubes(walls{i}(1:3)',walls{i}(4),walls{i}(5),walls{i}(6),walls{i}(7:9),0,0)
end

%% load lidar and oxts data for livesys
path1 = '~/Downloads/thesis/share/pcap_scenarios/';
%path2 = 'car/';
path2 = 'kitti_static_crossing/';
path3 = 'oxts/';
%path4 = 'pcd/1600to2200/';
path4 = 'pcd/';
%path4 = 'pcd/1550to1650/';

oxts = loadOxtsDir(strcat(path1,path2,path3));
lidarData = loadLidarDir(strcat(path1,path2,path4));

Num = length(lidarData);

for i=1:Num
    oxts{i}(2:end,:) = [];
    lidarData{i}(:,4:7) = [];
end

%% plot lidarData
figure;
for j=1:Num
    test = lidarData{j};
    pcshow(test)
    pause(0.3)
end

%% rotate the frames into lat lon coordinate system (x is east, y is north)
tic
liveFrames = cell(1,Num);
for i=1:Num
    liveFrames{i} = lidarData{i}*rotationMatrixXYZ(-oxts{i}(4),-oxts{i}(5),-oxts{i}(6));
end
toc

%% plot live frames vs. static geo map
figure;
for j=1:Num
    test = pointCloud(liveFrames{j});
    pcshow(test)
    hold on
    for i = 1:size(walls,1)
        plotCubes(walls{i}(1:3)',walls{i}(4),walls{i}(5),walls{i}(6),walls{i}(7:9),-2,walls{i}(3)-3)
    end
    hold off
    pause(0.2)
end

%% ground removal
cleanedFrames = cell(1,Num);
for i = 1:Num
    tic
    i
    cleanedFrames{i} = gridGroundRemoval(liveFrames{i}, 200, 0.45);
    fprintf('before: %6.2f, after: %6.2f\n', [size(liveFrames{i},1) size(cleanedFrames{i},1)]);
    toc
end

%% remove static points
mWalls = cell2mat(walls);
for i=1:Num
    tic
    i
    % remove points that are within the walls
    % sort walls by closest to current position first
    before = size(cleanedFrames{i},1);
    currentPos = [0 0 0]';
    currentPos = repmat(currentPos',11,1);
    [trash idx] = sort([sum(abs(mWalls(:,1:3)-currentPos),2)], 'ascend');
    mWalls = mWalls(idx,:);
    % remove all points that are within walls
    for j = 1:ceil(size(mWalls,1))
        cleanedFrames{i} = removePointsInsideCube(mWalls(j,:), cleanedFrames{i});
    end
    fprintf('before: %6.2f, after: %6.2f\n', [before size(cleanedFrames{i},1)]);
    toc
end

%% plot cleaned frames vs. static geo map
figure;
for j=1:Num
    pcshow(cleanedFrames{j})
%     hold on
%     for i = 1:length(walls)
%         plotCubes(walls{i}(1:3)',walls{i}(4),walls{i}(5),walls{i}(6),walls{i}(7:9),-0.5,walls{i}(3)-2)
%     end
%     for i = 1:length(poles)
%         plotCylinder(poles{i}(2:4)',poles{i}(1),poles{i}(5)+poles{i}(4),poles{i}(6))
%     end
%     hold off
    pause(0.3)
end