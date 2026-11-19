%%calculating the distance betweeen two points with known latitudes and longitudes%%
%% lon1,lat1 may give the known latitudes and longitudes at station 1, and lon2,lat2
%% are the others.
%% And the 'X' returns the east-west distance, 'Y' is north-south. 'L' returns  the distance%% 
%% between two stations.
function [X,Y,L]=lonlat(lon1,lon2,lat1,lat2);
CON=lat1*0.0174532925;
YMETER=111132.09-566.05*cos(2.*CON)+1.2*cos(4.*CON)-0.002*cos(6.*CON);
XMETER=111415.13*cos(CON)-94.55*cos(3.*CON)+0.012*cos(5.*CON);
X=(lon2-lon1)*XMETER;
Y=(lat2-lat1)*YMETER;
L=sqrt(X*X+Y*Y);
