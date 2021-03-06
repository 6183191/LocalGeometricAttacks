function [attackedImg, Dx, Dy, DxFinal, DyFinal] = ...
    directSmoothPyramid(imageIn, level, window, debug)
% Use multiscale representation (image pyramid) to design diretcional smoothing
% of displacement field
% <inputs>
%   imageIn: input image (can be color image)
%   level: level of the pyramid, can be 0,1,2,3,4,5,6,7
%   window: size of window used in C-LPCD
%   debug: if debug == 1, then display figures.
%
% <outputs>
%   attackedImg: attacked image
%   DxFinal: smoothed field, same size as input/output image
%   DyFinal: smoothed field, same size as input/output image
%
% <History>
%   Bin Yan, yanbinhit@hotmail.com, 2013.9.8

levelNum = level;

% Deal with color image.
if size(imageIn,3)>1
    imageInGray = double(rgb2gray(imageIn));
    imageInColor = imageIn;
else
    imageInGray = double(imageIn);
end

%Construct image pyramid
imgPyramid = genLowResolutionImg(imageInGray,levelNum , [5 5], 1.6);

% Design the displacement field on the top layer
[OrientMap, Coherence] = BlkSVDOrientDense(imgPyramid(levelNum+1).img, 1, debug);
[attackedImageNoSmooth, Dx, Dy, DxLow, DyLow] ...
    = CLPCD_outputField(num2str(window),num2str(level),imageInGray, debug);

% if level == 6
%     stdev = 1;
% elseif level == 5
%     stdev = 3;
% elseif level == 4
%     stdev = 7;
% else
%     disp('level not supported by MRF_mod');
% end
% [attackedImageNoSmooth, Dx, Dy, DxLow, DyLow] = MRF_mod(num2str(level),...
%                                                         num2str(stdev),...
%                                                         imageInGray,...
%                                                         debug);

[DxLowHat, DyLowHat] = SmoothField(DxLow, DyLow, OrientMap, Coherence); % 平滑偏移场

if debug == 1
    figure;
    imagesc(imgPyramid(levelNum+1).img); colormap(gray); hold on;
    quiver(1:size(DxLowHat,2), 1:size(DxLowHat,1), DxLowHat, DyLowHat);
end

DxHat{levelNum+1}.img = DxLowHat; % 用两个原胞数组存储偏移场金字塔
DyHat{levelNum+1}.img = DyLowHat;

% Design the lower layer of the displacement field from the upper layers
for iLayer = (levelNum-1) : -1 : 0
    [OrientMapParent, CoherenceParent] ...
        = BlkSVDOrientDense(imgPyramid(iLayer+2).img, 1, debug);
    [OrientMapCurrent, CoherenceCurrent] ...
        = BlkSVDOrientDense(imgPyramid(iLayer+1).img, 1, debug);
    [nRowsCurrent, nColsCurrent] = size(OrientMapCurrent);
    DxCurrent = imresize(DxHat{iLayer+2}.img,[nRowsCurrent, nColsCurrent],'bilinear');
    DyCurrent = imresize(DyHat{iLayer+2}.img,[nRowsCurrent, nColsCurrent],'bilinear');
    CoherenceMapP = imresize(CoherenceParent,[nRowsCurrent, nColsCurrent],'bilinear');
    
    % show the displacement inherited from the parents layer 
    if debug == 1
        figure;imagesc(imgPyramid(iLayer+1).img); colormap(gray); hold on;
        quiver(1:size(DxCurrent,2),1:size(DyCurrent,1),...
            DxCurrent, DyCurrent);
        title('displacement field');
    end
    
    [DxHat{iLayer+1}.img, DyHat{iLayer+1}.img] = ...
        SmoothField(DxCurrent, DyCurrent, OrientMapCurrent, CoherenceCurrent); % 平滑偏移场
%     for iter = 1:(7-iLayer)*2
%         if debug ==1 
%             ['layer=', num2str(iLayer), ', iter=', num2str(iter)]
%         end
%         [DxHat{iLayer+1}.img, DyHat{iLayer+1}.img] = ...
%             SmoothField(DxHat{iLayer+1}.img, DyHat{iLayer+1}.img, OrientMapCurrent, CoherenceCurrent);
%     end
    
    % %Compare the coherence of the adjancent layers, and filter the current layer
    % % only when the coherence of the current layer is higher.
    % [DxHat{iLayer+1}.img, DyHat{iLayer+1}.img] = ...
    %     SmoothFieldLayers(DxCurrent, DyCurrent, ...
    %     OrientMapCurrent, CoherenceCurrent,...
    %     CoherenceMapP);
    % for iter = 1:(9-iLayer)*2
    %     ['layer=', num2str(iLayer), ', iter=', num2str(iter)]
    %     [DxHat{iLayer+1}.img, DyHat{iLayer+1}.img] = ...
    %         SmoothFieldLayers(DxHat{iLayer+1}.img, DyHat{iLayer+1}.img, ...
    %         OrientMapCurrent, CoherenceCurrent, CoherenceMapP);
    % end
    
end
DxFinal = DxHat{1}.img ;
DyFinal = DyHat{1}.img ;

% Show the final displacement field
if debug
    figure;imagesc(imgPyramid(1).img); colormap(gray); hold on;
    quiver(1:size(DxHat{1}.img,2),1:size(DyHat{1}.img,1),...
        DxHat{1}.img, DyHat{1}.img);
    title('Displacement field after the multiscale smoothing');
end

 

% Apply the displacement field to image
if size(imageIn,3)>1
    for ii = 1:3
        attackedImg(:,:,ii) = DistortImg(imageInColor(:,:,ii), DxHat{1}.img, DyHat{1}.img);
    end
else
    attackedImg = DistortImg(imageInGray, DxHat{1}.img, DyHat{1}.img);
end

if debug
    if size(imageIn,3)>1
    figure;
    Dmax = ceil(max([max(DxFinal(:)), max(DyFinal(:))])); %determing cropping parameters
    for kk = 1:10
        idxX = Dmax:size(imageInColor,1)-Dmax;
        idxY = Dmax:size(imageInColor,2)-Dmax;
        imshow(imageInColor(idxX,idxY,:)); title('original image');drawnow; pause(1);
        imshow(attackedImg(idxX,idxY,:)); title('attacked image');drawnow; pause(1);
    end
    end
end


end % end of main function



% subroutine
%====================================================================
% generate low resolution image
%===================================================================
function imgOut = genLowResolutionImg(imgIn, level,sizeMask, sigma )
% Note: for output, the level starts from 1 ( 1 == original resolution)
filterMask = fspecial('gaussian',sizeMask,sigma);
for i = 0:level
    if i == 0
        imgOut(1).img = imgIn;
    else
        imgTemp =  imfilter(imgOut(i).img, filterMask,'symmetric', 'conv');
        [rows, cols] = size(imgTemp);
        imgOut(i+1).img = imgTemp(1:2:rows, 1:2:cols);
    end
end
end