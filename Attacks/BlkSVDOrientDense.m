function [Orient, Coherence] = BlkSVDOrientDense(A,sz,option)
%=========================================================================
% Similar to BlkSVDOrient, but the estimated orientation field is dense. 
% i.e. the size of the field is the same as the size of the image.
%=========================================================================

BlkSize=sz;
[nRows, nCols] = size(A);
Orient = zeros(nRows, nCols);
Coherence = zeros(nRows, nCols);

% calculate the gradient map
[fx,fy]=gradient(A);
G=complex(fx,fy);

% Load the SVD method by blocks
% Orient=nlfilter(G,[BlkSize,BlkSize],'SVD_Orientation');
%%ԭ���ĳ����������������

if option 
    h = waitbar(0,'calculating local orientation');
end;
for i = sz+1 : nRows-sz
    for j = sz+1 : nCols-sz
        [Orient(i,j), c] = SVD_Orientation(G(i-sz+1:i+sz, j-sz+1:j+sz));
        if c(1)< eps || c(2)<eps
            Coherence(i,j) = 0;
        else
            Coherence(i,j) = abs((c(1)-c(2))/(c(1)+c(2)));
            %Coherence(i,j) = c(1) - c(2); %����ô�coherence������������Ը�˹�˲���
                                           % �����޸ġ���������ù�һ�����coherence
        end
        
    end
    if option
        waitbar(i/nRows,h);
    end
end
if option
    close(h);
end

% show the estimation result
if option == 1
    OrientSmp = Orient(1:BlkSize:size(Orient,1), 1:BlkSize:size(Orient,2));
    CoherenceSmp = Coherence(1:BlkSize:size(Orient,1), 1:BlkSize:size(Orient,2));
    ShowOrientationCoherence(OrientSmp,CoherenceSmp, A);
    title('Orientation Map (vector length is modulated by coherence)');
end
