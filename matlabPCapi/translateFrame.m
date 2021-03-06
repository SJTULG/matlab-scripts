function translatedFrame = translateFrame(pcdXYZ, gpsStatic, gpsLive)
% translates the current live frame in XYZ in relation to a static environment 
% according to a difference between static/live GPS and static/live altitude
% in:
%   pcdXYZ -        Nx3 matrix, [x, y, z]
%   gpsStatic -     1x3 vector, old frame position, [lat, lon, alt] deg,deg,m
%   gpsLive -       1x3 vector new frame position, [lat, lon, alt] deg,deg,m
% out:
%   translatedFrame -  Nx3 matrix, [x, y, z]

xyDiff = gpsDiff2xyDiff(gpsLive(1:2), gpsStatic(1:2));
zDiff = gpsLive(3) - gpsStatic(3);
xyzDiff = [xyDiff zDiff]; %1x3

%translate for x, y and z
%e.g. if the position difference is x=+1 then
%the live frame has to add that difference
%to all its coordinates
pcdXYZ(:,1) = pcdXYZ(:,1) + xyzDiff(1);
pcdXYZ(:,2) = pcdXYZ(:,2) + xyzDiff(2);
pcdXYZ(:,3) = pcdXYZ(:,3) + xyzDiff(3);
translatedFrame = pcdXYZ;

end