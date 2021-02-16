function [y, name, pnames, pin]=NixGao(x,p, flag)

if nargin==2;
    hstar = (81/2).*(((3.^0.5)/2).*0.351.*10.^(-9)).*(0.5.^2).*(0.358.^2).*(p(:,1)./p(:,2)).^2;
    y=p(:,2).*((1+hstar./x)).^0.5;
else
	y=[];
	name='gaussian';
	pnames=str2mat('Amplitude','Centre','Width','Background');
	if flag==1, pin=[0 0 1 1]; else pin = p; end
	if flag==2
		mf_msg('Click on peak');
		[cen amp]=ginput(1);
		mf_msg('Click on width');
		[width y]=ginput(1);
		width=abs(width-cen);
		mf_msg('Click on background');
		[x bg]=ginput(1);
		amp=amp-bg;
		pin=[amp cen width bg];
	end
end