function [DxHat, DyHat] = SmoothField(Dx, Dy, OrientMap, Coherence)
%===========================================================================
% Smooth the displacement field according to the orientation map. Smooth
% only the component along the edge direction ( the max eigenvalue
% direction )
% 
% <inputs>
%   Dx: Displacement field along the x direction (horizontal or first dim)
%   Dy: Displacement field along the y direction (vertical or second dim)
%   OrientMap: Orientation map obtained from the input image��
%       �Է���������ʾ��ÿ�������ϵķ���������һ��������ʾ��ʵ����ʾx������
%       �鲿��ʾy������
%       ָ��Ҷȱ仯���ķ��򣨱�Ե����
%   Coherence: a quantity between 0 and 1, with 1 indicating coherence
%           local structure, ex. simple neighbourhood
%
% <outputs>
%   DxHat: Smoothed displacement field along the x direction
%   DyHat: Smoothed displacement field along the y direction
%
% <author>
%   Bin Yan. 2013.4.4  
%==========================================================================

% Important parameters
sigma = 2;   % sigma used in Gaussian filter kernel
sizeWin = 7; % should be an odd number, ex: 3, 5, 7, 9.
halfSizeWin = floor(sizeWin/2);

% check if the size of Dx, Dy and OrientMap are the same
% omitted for the moment

[nRows, nCols] = size(Dx);
% DxHat = zeros(nRows, nCols);
% DyHat = zeros(nRows, nCols);
% filterMask =  fspecial('gaussian', sizeWin, sigma);  % ����ͬ�Ը�˹�˲�����
Dx = padarray(Dx, [halfSizeWin halfSizeWin], 'replicate', 'both');
Dy = padarray(Dy, [halfSizeWin halfSizeWin], 'replicate', 'both');
DxHat = zeros(size(Dx));
DyHat = zeros(size(Dy));

for i = (halfSizeWin+1) : (nRows+halfSizeWin)        
    for j = (halfSizeWin+1) : (nCols + halfSizeWin)    
        % ���Dx�� Dy����û��λ�ƣ��򲻱�ƽ������Ϊ��
        if (abs(Dx(i,j)) < eps) &  (abs(Dy(i,j)) < eps)
            DxHat(i,j) = 0; 
            DyHat(i,j) = 0; 
        end
        
        % �Դ�������(i,j)�ľֲ�����Ϊ�����ᣬ�Ľ������ڵ�λ��ʸ��������������
        % �ֽ⣬ƽ���ر�Ե����ķ���
        
        % ȡһ��С�����ڵ�λ�Ƴ���
        dxPatch = zeros(sizeWin, sizeWin);
        dyPatch = zeros(sizeWin, sizeWin);
        for k = -halfSizeWin: halfSizeWin
            for l = -halfSizeWin: halfSizeWin
                dxPatch(k+halfSizeWin+1, l+halfSizeWin+1) = Dx(i+k, j+l);
                dyPatch(k+halfSizeWin+1, l+halfSizeWin+1) = Dy(i+k, j+l);
            end
        end
        ip = i - halfSizeWin;
        jp = j - halfSizeWin;
        % ����ƽ��
        filterMask = genAnisotropicGaussMask(sizeWin, sigma, ...
                                             OrientMap(ip,jp), Coherence(ip,jp)); 
                                                      % �����������Ը�˹��
        [DxHat(i,j), DyHat(i,j)] = ...
            averageVecFieldDirection(dxPatch, dyPatch, OrientMap(ip,jp), ...
                                        Coherence(ip,jp), filterMask);
        
    end
end
DxHat = DxHat((halfSizeWin+1) : (nRows+halfSizeWin), (halfSizeWin+1) : (nCols + halfSizeWin));
DyHat = DyHat((halfSizeWin+1) : (nRows+halfSizeWin), (halfSizeWin+1) : (nCols + halfSizeWin));
end

%======================================================================
% �ӳ��򣺲����������Ը�˹��
%======================================================================
function mask = genAnisotropicGaussMask(sizeWin, sigma, orient, c)
% c: coherence
winSizeHalf = floor(sizeWin/2);
varD = sigma^2;
alpha = 1/3;  % alpha =1 ����Բƫ������Ϊ4��alpha = 1/2,����Բƫ������Ϊ9.
ve = [ real(orient);imag(orient)]; % edge direction
if ve(2)<0    % �Ƕ������ڣ�0, pi] ֮��
    ve(1) = -ve(1);
    ve(2) = -ve(2);
end
vf = [-imag(orient); real(orient)];% flow direction
if vf(2) <0
    vf(1) = -vf(1);
    vf(2) = -vf(2);
end

Ad = (1/varD) .* [ve vf] * diag([((alpha+c)/alpha)^2, (alpha/(alpha+c))^2]) ...
    * [ve vf]';  % ��Ȩ���� (not covariance matrix!!)
mu = [0; 0];
[px,py] = meshgrid(-winSizeHalf:1:winSizeHalf, -winSizeHalf:1:winSizeHalf);
mask = genMvGaussianMask(px, py, mu, Ad);
% normalize the mask
mask = mask ./(sum(sum(mask)));
end
