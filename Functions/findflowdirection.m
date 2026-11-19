%% Calculate the angle in current directory
function xdir = findflowdirection(u,v)
for i=1:length(u)
    if u(i)>0
    xdir(i)=90-(atand(v(i)/u(i)));
    elseif u(i)<0 
    xdir(i)=270-(atand(v(i)/u(i)));
    elseif u(i)==0 & v(i)>0 
        xdir(i)=0;
    elseif u(i)==0 & v(i)<0 
        xdir(i)=180;
    elseif v(i)==0 & u(i)<0 
        xdir(i)=270;
    elseif v(i)==0 & u(i)>0 
        xdir(i)=90;
    end
end