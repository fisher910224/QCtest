function psd_corr = apply_kp_correction(psd, freq, h, g)
    psd_corr = zeros(size(psd));
    kp_min = 0.086; % USACE

    for i = 1:length(freq)
        f = freq(i);
        
       
        if f < 0.001
            psd_corr(i) = psd(i);
            continue;
        end
        
        
        omega = 2 * pi * f;
        k = omega^2 / g; 
        
        for iter = 1:5
            f_k = g * k * tanh(k * h) - omega^2;
            df_k = g * tanh(k * h) + g * k * h * (sech(k * h))^2;
            k = k - f_k / df_k;
        end
        

       
        Kp = 1 / cosh(k * h);
        
        
        Kp_effective = max(Kp, kp_min);
        
        
        psd_corr(i) = psd(i) / (Kp_effective^2);
    end
end