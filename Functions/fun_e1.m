function E= fun_e1(theta, data)
x=data(:,1);
y=data(:,2);
% K1 O1 M2 S2 
model_y=theta(1)+theta(2)*cos(2*pi*x/23.93-theta(3))+theta(4)*cos(2*pi*x/25.82-theta(5))...
    +theta(6)*cos(2*pi*x/12.42-theta(7))+theta(8)*cos(2*pi*x/12.00-theta(9));
E = sum((y-model_y).^2);