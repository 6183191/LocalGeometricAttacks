function [DxHat, DyHat] = averageVecFieldDirection(Dx, Dy, Orient, Coherence, filterMask)
%===========================================================================================
% averageVecFildDirection: ʹ���˲���filterMask ������ Orient ����ķ����˲��� 
%                          ���ִ�ֱOrient����ķ�������
% ���أ���������ֵ��
% ע�� ��������SmoothField.m��ͬ��������ֻ���һ�飨patch)���ݡ�
%
% <inputs>
%   Dx: a patch of the displacement field along the x direction
%   Dy: a patch of the displacement field along the y direction
%   Orient: a complex number representing a unit vector, i.e., the
%       orientation vector (along the edge direction, i.e. the direction of
%       max change
%   filterMask: smoothing kernel used to smooth the displacement field
%          along the edge direction
%   Coherence: coherence measure of local neighbour, [0,1] 
%
% <outputs>
%   DxHat: smoothed displacement along x direction at the center of the
%           patch
%   DyHat: smoothed displacement along y direction at the center of the
%           patch
%
% <author>
%   Bin Yan, 2013. 4. 13 Created.
% 
% <modification>
%   1. (2013.4.20) ����coherence������coherence �ߵĲ��ֲ���Ҫƽ����coherence �͵Ĳ����ݲ���Ҫƽ��
%============================================================================================
CoherenceThr = 0;  % 0: ������һ���Ե�Ӱ�죬 0.5�� ����ֵ������һ���Ե�Ӱ�졣

patSize = size(filterMask, 1); % size of patch is =  patSize x patSize

% ���coherence measure ��С���򱾿鲻��Ҫƽ�������ش������Ĵ���λ������
if Coherence <= CoherenceThr
    DxHat = Dx( floor(patSize/2)+1,floor(patSize/2)+1 );
    DyHat = Dy( floor(patSize/2)+1,floor(patSize/2)+1 );
    return;
end
%==========================================================================
% STEP#1: �����е�ÿ��displacementʸ���ֽ�Ϊ��orient����ʹ�ֱorient����ķ���
%==========================================================================
Dp = zeros(patSize, patSize);
Do = zeros(patSize, patSize);

Or = real(Orient); % ��Ե�ķ��򣬽�������Ϊ[0, pi]֮��
Oi = imag(Orient);
if Oi < 0 
    Oi = -Oi;
    Or = -Or;
end

for i=1:patSize
    for j=1:patSize
        Dp(i,j) = Dx(i,j)* Or + Dy(i,j) * Oi;
        
        % ���local orientation (v,u),i.e.,��Orient�����ķ���(����flow direction)
        % �����н�����Ϊ[0, pi]֮�䡣
        v = - Oi;
        u = Or;
        if (u<0)
            v = -v;
            u = -u;
        end
        
        Do(i,j) = Dx(i,j)* v + Dy(i,j) * u;
    end
end

%====================================================================
% STEP#2: ƽ��Dp��������ƽ�����ű�Ե����ķ���������������ķ��������仯
%====================================================================
filterMask = filterMask ./ (sum(sum(filterMask)));
DpHat = sum(sum(filterMask .* Dp));
%DpHat = 0; % ȥ����Ե�����λ�ơ�
DoHat = Do(floor(patSize/2)+1,floor(patSize/2)+1);

% % �����ã������κ�ƽ�����ֽ��ֱ���ؽ���
%  DpHat = Dp(floor(patSize/2)+1,floor(patSize/2)+1);
%  DoHat = Do(floor(patSize/2)+1,floor(patSize/2)+1);


%====================================================================
% STEP #3: �ع�x�����y�����λ�Ƴ�
%====================================================================
DxHat = DpHat * Or + DoHat * v;
DyHat = DpHat * Oi + DoHat * u;

% % �����ã�����ƽ����ֱ���������λ�Ƴ�
% DxHat = Dx(floor(patSize/2)+1,floor(patSize/2)+1);
% DyHat = Dy(floor(patSize/2)+1,floor(patSize/2)+1);

