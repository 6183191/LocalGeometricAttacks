function convertTestImages()
close all; clear;
%% ��¥
img = imread('L:\00-Projects\00-DesynAttack\code\Images\zhonglou.jpg');

imshow(img);
size(img)
%imgG = rgb2gray(img);
imgF = img(1:851, 250:250+850,:);
imgF = imresize(imgF, 512/851);
size(imgF)
imshow(imgF);
imwrite(imgF, 'zhonglou512.bmp','bmp');

%% �ݷ�¥
img = imread('L:\00-Projects\00-DesynAttack\code\Images\yifulou.jpg');
imshow(img);
size(img)
%imgG = rgb2gray(img);
imgF = img(1:851, 250:250+850,:);
imgF = imresize(imgF, 512/851);
size(imgF)
imshow(imgF);
imwrite(imgF, 'yifulou512.bmp','bmp');

%% �Ƽ�԰
img = imread('L:\00-Projects\00-DesynAttack\code\Images\SKD-sciencepark.jpg');
imshow(img);
size(img)
%imgG = rgb2gray(img);
imgF = img(1:size(img,1), 250:250+size(img,1)-1,:);
imgF = imresize(imgF, 512/size(img,1));
size(imgF)
imshow(imgF);
imwrite(imgF, 'kejiyuan512.bmp','bmp');

%% ɽ����԰
img = imread('L:\00-Projects\00-DesynAttack\code\Images\SKD-shanhaihuayuan.jpg');
imshow(img);
size(img)
%imgG = rgb2gray(img);
imgF = img(1:size(img,1), 250:250+size(img,1)-1,:);
imgF = imresize(imgF, 512/size(img,1));
size(imgF)
imshow(imgF);
imwrite(imgF, 'shanhaihuayuan512.bmp','bmp');


%% ͼ���
img = imread('L:\00-Projects\00-DesynAttack\code\Images\SKD-Library.jpg');
imshow(img);
size(img)
%imgG = rgb2gray(img);
imgF = img(1:size(img,1), 140:140+size(img,1)-1,:);
imgF = imresize(imgF, 512/size(img,1));
size(imgF)
imshow(imgF);
imwrite(imgF, 'tushuguan512.bmp','bmp');

%% robotic¥
img = imread('L:\00-Projects\00-DesynAttack\code\Images\SKD-roboticCenter.jpg');
imshow(img);
size(img)
%imgG = rgb2gray(img);
imgF = img(1:size(img,1), 1:1+size(img,1)-1,:);
imgF = imresize(imgF, 512/size(img,1));
size(imgF)
imshow(imgF);
imwrite(imgF, 'roboticcenter512.bmp','bmp');



