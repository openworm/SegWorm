% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

tic;
eccArray = NaN(500, 1);
angleArray = NaN(500, 1);

for i = 1:500
    x = [normBlock1{2}(:,1,i); normBlock1{3}(end:-1:1,1,i)];
    y = [normBlock1{2}(:,2,i); normBlock1{3}(end:-1:1,2,i)];
    
    if all(~isnan(x)) || all(~isnan(y))
        [eccArray(i) angleArray(i)] = getPolyEccentricity(y, x);
    end
end
toc;

tic;
eccArray2 = NaN(500, 1);
angleArray2 = NaN(500, 1);

for i = 1:500
    x = [normBlock1{2}(:,1,i); normBlock1{3}(end:-1:1,1,i)];
    y = [normBlock1{2}(:,2,i); normBlock1{3}(end:-1:1,2,i)];
    
    if all(~isnan(x)) || all(~isnan(y))
        
        x = x - min(x) + 1;
        y = y - min(y) + 1;
        
        BW = poly2mask(x, y, ceil(max(y)), ceil(max(x)));
        
        regionStats = regionprops(BW, 'eccentricity', 'orientation');
        
        eccArray2(i) = regionStats.Eccentricity;
        angleArray2(i) = regionStats.Orientation;
    end
    
end
toc;

tic;
eccArray3 = NaN(500, 1);
angleArray3 = NaN(500, 1);

for i = 1:500
    x = [normBlock1{2}(:,1,i); normBlock1{3}(end:-1:1,1,i)];
    y = [normBlock1{2}(:,2,i); normBlock1{3}(end:-1:1,2,i)];    
    if all(~isnan(x)) || all(~isnan(y))
        [eccArray3(i) angleArray3(i)] = getOutlineEccentricity(x, y);
    end
end
toc;

tic;
eccArray4 = NaN(500, 1);
angleArray4 = NaN(500, 1);

for i = 1:500
    x = [normBlock1{2}(:,1,i); normBlock1{3}(end:-1:1,1,i)];
    y = [normBlock1{2}(:,2,i); normBlock1{3}(end:-1:1,2,i)];    
    if all(~isnan(x)) || all(~isnan(y))
        [eccArray4(i) angleArray4(i)] = getEccentricity(x, y, 50);
    end
end
toc;


figure;
plot(1:500, eccArray, 1:500, eccArray2, 1:500, eccArray3, 1:500, eccArray4)
figure;
plot(1:500, angleArray, 1:500, angleArray2, 1:500, angleArray3, 1:500, angleArray4)
