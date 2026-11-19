function [k,L]=dpr_nt(T,h)
    %{
    ----------------------------------------------------------------------
      Computatio of wavenumber and wavelength using linear dispersion
      relation solved by Newton's iteration method
      INPUT 
          T: wave period (can be a vector)
          h: water depth (can be a vector)
      OUTPUT
          k: wavenumber 
          L: wavelength
      by Zhi-Cheng Huang 2011
    ---------------------------------------------------------------------
    %}
    nj=length(T);
    nh=length(h);
    if nh<nj, h(1:nj)=h; end
    for j=1:nj
        x1(j)=2*pi*h(j)/(1.56*T(j)^2);
        c1(j)=x1(j);
        ind(j)=1.;
        while ind(j)>10^-5
        a1(j)=x1(j)*tanh(x1(j))-c1(j);
        a2(j)=tanh(x1(j)) + x1(j)*sech(x1(j))^2;
        x2(j)=x1(j)-a1(j)/a2(j);
        ind(j)=abs(x2(j)-x1(j));
        x1(j)=x2(j);
        x2(j)=0.;
        end 
    k(j)=x1(j)/h(j);
    L(j)=2*pi/k(j);     
    end
   
    