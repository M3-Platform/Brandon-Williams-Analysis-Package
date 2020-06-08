%INPUT: 
%-cim: mean frame FOV 
%-htresh: high pass filter value
%-ltresh: low pass filter value
%OUTPUT:
%-
function [out] = fourrierfilter(cim,hthresh,lthresh)
%read input image
% dim=imread('lena.pgm');
cim=double(cim);
[r,c]=size(cim);

r1=2*r;
c1=2*c;

pim=zeros((r1),(c1));
kim=zeros((r1),(c1));

%padding
for i=1:r
    for j=1:c
        pim(i,j)=cim(i,j);
    end
end

%center the transform
for i=1:r
    for j=1:c
        kim(i,j)=pim(i,j)*((-1)^(i+j));
    end
end


%2D fft
fim=fft2(kim);

n=4; %order for butterworth filter
% hthresh=10; % cutoff radius in frequency domain for filters
% lthresh = 70;

% % function call for low pass filters
fim =glp(fim,lthresh); % gaussian low pass filter
% him=blpf(fim,thresh,n); % butterworth low pass filter

% % function calls for high pass filters
him=ghp(fim,hthresh); % gaussian low pass filter
%  him=bhp(fim,hthresh,n);  %butterworth high pass filter

% % function call for high boost filtering
% him=hbg(fim,thresh);  % using gaussian high pass filter
%  him=hbb(fim,thresh,n);  % using butterworth high pass filter


%inverse 2D fft
ifim=ifft2(him);

for i=1:r1
    for j=1:c1
        ifim(i,j)=ifim(i,j)*((-1)^(i+j));
    end
end


% removing the padding
for i=1:r
    for j=1:c
        rim(i,j)=ifim(i,j);
    end
end

% retaining the real parts of the matrix
rim=real(rim);
out =double(rim);
end