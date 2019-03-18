function attackedImg = DistortImg(imgIn, Dx, Dy)
%==========================================================================
% ʹ�ø�����displacement field�� Dx �� Dy ������ͼ��imgIn ��
%==========================================================================

[nRows, nCols] = size(imgIn);

% ��� imgIn, Dx, Dy ���ߵĳߴ��Ƿ�һ��.
% �Ժ�����
maxD = ceil(max([max(Dx(:)), max(Dy(:))]));
for i = 1 : nRows
    for j = 1 : nCols
        rowIdx(i,j) = j + Dx(i,j);
        colIdx(i,j) = i + Dy(i,j);
    end
end
%imgIn = padarray(imgIn, [maxD maxD], 'replicate','both');
att = interp2(double(imgIn),rowIdx,colIdx, 'bicubic');
attackedImg = uint8(att);