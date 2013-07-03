classdef RGBImage < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        red = [];
        green = [];
        blue = [];
    end
    
    methods
        function obj = size(obj, width, height)
            if size(obj.red, 1) ~= height || size(obj.red, 2) ~= width
                obj.red = zeros(height, width);
                obj.green = zeros(height, width);
                obj.blue = zeros(height, width);
            end
        end
        function obj = copy(obj, img)
            if ndims(img) == 3
                if size(img, 1) == size(obj.red, 1) && ...
                        size(img, 2) == size(obj.red, 2)
                    obj.red(:,:) = img(:,:,1);
                    obj.green(:,:) = img(:,:,2);
                    obj.blue(:,:) = img(:,:,3);
                else
                    obj.red = img(:,:,1);
                    obj.green = img(:,:,2);
                    obj.blue = img(:,:,3);
                end
            else
                if isequal(size(img), size(obj.red))
                    obj.red(:,:) = img;
                    obj.green(:,:) = img;
                    obj.blue(:,:) = img;
                else
                    obj.red = uint8(img);
                    obj.green = uint8(img);
                    obj.blue = uint8(img);
                end
            end
        end
    end
end

