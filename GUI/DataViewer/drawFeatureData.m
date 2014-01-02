function drawFeatureData(dataBlock, j, axesName, item_selected, signVal, verbose)
% DRAWFEATUREDATA This funciton will compute and draw feature data to the
% data viewer.
% Input:
%   dataBlock - segmentation data
%   j - frame of interest
%   axesName - axes name for drawing
%   item_selected - current feature being viewed
%   signVal - experiment view orientation variable
%   verbose - bolean argument
% Output:
% -
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.
if dataBlock{1}(j) == 's'
    % Here we will select what to draw depending on the item_selected value
    skCoords = dataBlock{4}(:,:,j);
    % rotate the skeleton accordingly to the viewer
    skCoords = [skCoords(:,1)*signVal(1,1),skCoords(:,2)*signVal(1,2)];
    
    outlineCoordsVulvaSide = dataBlock{2}(:,:,j);
    outlineCoordsVulvaSide = [outlineCoordsVulvaSide(:,1)*signVal(1,1), outlineCoordsVulvaSide(:,2)*signVal(1,2)];
    
    outlineCoordsNonVulvaSide = dataBlock{3}(:,:,j);
    outlineCoordsNonVulvaSide = [outlineCoordsNonVulvaSide(:,1)*signVal(1,1), outlineCoordsNonVulvaSide(:,2)*signVal(1,2)];
    
    if strcmp(item_selected, 'eccentricity') || strcmp(item_selected, 'wavelength1') || strcmp(item_selected, 'wavelength2') || strcmp(item_selected, 'amplitudeCronin')
        
        varB = outlineCoordsNonVulvaSide;
        varA = outlineCoordsVulvaSide;
        var1 = [varA(1:end-1,:); flipud(varB(2:end,:))];
        
        minVal1 = min(min(var1(:,1)));
        dim1 = max(round(var1(:,1) - minVal1));
        
        minVal2 = min(min(var1(:,2)));
        dim2 = max(round(var1(:,2) - minVal2));
        img1 = zeros(dim1, dim2);
        
        outlineCoordsRec = [var1(:,1) - minVal1, var1(:,2) - minVal2];
        img2 = roipoly(img1, outlineCoordsRec(:, 2), outlineCoordsRec(:,1));
        s = regionprops(img2, 'Orientation', 'Eccentricity', 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Area');
        % In case there is a whip or other artifacts - we
        % choose the biggest connected component
        if length(s) > 1
            [~,ind1] = max([s.Area]);
            s = s(ind1);
        end
        
        %Display eccentricity
        %axes(axesName);
        if strcmp(item_selected, 'eccentricity') && verbose
            img2 = bwperim(img2, 8);
            newImg = img2;
            img3 = zeros(round(size(newImg) * 1.5));
            offset1 = 100;
            img3(offset1:size(newImg, 1) + offset1 - 1, offset1:size(newImg,2) + offset1 - 1) = newImg;
            imshow(img3);
            hold on;
            phi = linspace(0,2*pi,50);
            cosphi = cos(phi);
            sinphi = sin(phi);
            
            for k = 1:length(s)
                xbar = s(k).Centroid(1);
                ybar = s(k).Centroid(2);
                
                a = s(k).MajorAxisLength/2;
                b = s(k).MinorAxisLength/2;
                
                theta = pi*s(k).Orientation/180;
                R = [ cos(theta)   sin(theta)
                    -sin(theta)   cos(theta)];
                
                xy = [a*cosphi; b*sinphi];
                xy = R*xy;
                
                x = xy(1,:) + xbar;
                y = xy(2,:) + ybar;
                
                plot(x+offset1,y+offset1,'r','LineWidth',2);
            end
            hold off;
        end
        if strcmp(item_selected, 'wavelength1') || strcmp(item_selected, 'wavelength2') || strcmp(item_selected, 'amplitudeCronin')
            wormLen = dataBlock{7}(j);
            [ampt, wavelnth] = getAmpWavelength(-s.Orientation*(pi/180), skCoords, wormLen, axesName, verbose, item_selected, j);
        end
        
    elseif strcmp(item_selected, 'amplitudeBaek')
        % amplitude
        
        %calculating approx amplitude
        %first, lets get the line equation for the end points of
        %the skeleton  http://math.ucsd.edu/~wgarner/math4c/derivations/distance/distptline.htm
        endPoints = skCoords([1,end],:);
        %getting line equation
        [newLine, m, b, lineMode, c] = getLineCoeff(endPoints, 2);
        %lineCoeff = polyfit(endPoints(:,2),endPoints(:,1),1);
        
        if lineMode==3
            %normal line
            pepDist = (skCoords(:,1)-m*skCoords(:,2)-b)/sqrt(m^2+1);
        elseif lineMode==1
            %vertical line
            pepDist = skCoords(:,2)-c;
        elseif lineMode==2
            %horizontal line
            pepDist = skCoords(:,1)-c;
        end
        
        indLookup = 1:length(pepDist);
        allPeaks = [];
        if isempty(pepDist(pepDist>0)) || max(abs(pepDist(pepDist>0))) == 0
            skelAmp = max(abs(pepDist(pepDist<0)));
            skelAmpR = 0;
            allPeaks(1) = indLookup(pepDist==min(pepDist(pepDist<0)));
        elseif isempty(pepDist(pepDist<0)) || max(abs(pepDist(pepDist<0))) == 0
            skelAmp = max(abs(pepDist(pepDist>0)));
            skelAmpR = 0;
            allPeaks(1) = indLookup(pepDist==max(pepDist(pepDist>0)));
        else
            skelAmp = max(abs(pepDist(pepDist>0))) + max(abs(pepDist(pepDist<0)));
            skelAmpR = min(max(abs(pepDist(pepDist>0))), max(abs(pepDist(pepDist<0))))/...
                max(max(abs(pepDist(pepDist>0))), max(abs(pepDist(pepDist<0))));
            % get the indexes
            allPeaks(1) = indLookup(pepDist==min(pepDist(pepDist<0)));
            allPeaks(2) = indLookup(pepDist==max(pepDist(pepDist>0)));
        end
        skelAmplitude = skelAmp;
        skelAmpRatio = skelAmpR;
        
        % Draw amplitude
        if verbose
            plot(skCoords(:,1), skCoords(:,2));
            axis equal;
            hold on;
            line(endPoints(:,1),endPoints(:,2), 'Color', 'r');
            
            % Find the closes point on the line between head and tail from the
            % peak point on the skeleton
            x1 = endPoints(1,1);
            y1 = endPoints(1,2);
            x2 = endPoints(2,1);
            y2 = endPoints(2,2);
            %--
            x3 = skCoords(allPeaks(1),1);
            y3 = skCoords(allPeaks(1),2);
            %--
            a1 = (y2-y1)/(x2-x1);
            b1 = y1 - a1*x1;
            a2 = -1/a1;
            b2 = y3 - a2*x3;
            
            xInt1 = -(b1 - b2)/(a1 - a2);
            yInt1 = a1 * xInt1 + b1;
            
            
            if length(allPeaks) >= 2
                x3 = skCoords(allPeaks(2),1);
                y3 = skCoords(allPeaks(2),2);
                %--
                a1 = (y2-y1)/(x2-x1);
                b1 = y1 - a1*x1;
                a2 = -1/a1;
                b2 = y3 - a2*x3;
                
                xInt2 = -(b1 - b2)/(a1 - a2);
                yInt2 = a1 * xInt2 + b1;
                
                line([skCoords(allPeaks(1),1),xInt1], [skCoords(allPeaks(1),2),yInt1],  'Color', 'b');
                text(skCoords(allPeaks(1),1), skCoords(allPeaks(1),2),'*', 'FontSize', 18, 'Color', 'r');
                text(xInt1, yInt1,'*', 'FontSize', 18, 'Color', 'r');
                text(sum([skCoords(allPeaks(1),1),xInt1])/2, sum([skCoords(allPeaks(1),2),yInt1])/2, num2str(max(abs(pepDist(pepDist<0)))), 'FontSize', 10, 'Color', 'r');
                
                line([skCoords(allPeaks(2),1),xInt2], [skCoords(allPeaks(2),2),yInt2],  'Color', 'b');
                text(skCoords(allPeaks(2),1), skCoords(allPeaks(2),2),'*', 'FontSize', 18, 'Color', 'b');
                text(xInt2, yInt2,'*', 'FontSize', 18, 'Color', 'b');
                text(sum([skCoords(allPeaks(2),1),xInt2])/2, sum([skCoords(allPeaks(2),2),yInt2])/2, num2str(max(abs(pepDist(pepDist>0)))), 'FontSize', 10, 'Color', 'b');
            else
                line([skCoords(allPeaks(1),1),xInt1], [skCoords(allPeaks(1),2),yInt1],  'Color', 'b');
                text(skCoords(allPeaks(1),1), skCoords(allPeaks(1),2),'*', 'FontSize', 18, 'Color', 'r');
                text(xInt1, yInt1,'*', 'FontSize', 18, 'Color', 'r');
                text(sum([skCoords(allPeaks(1),1),xInt1])/2, sum([skCoords(allPeaks(1),2),yInt1])/2, num2str(skelAmp), 'FontSize', 10, 'Color', 'r');
            end
            hold off;
        end
    end
end