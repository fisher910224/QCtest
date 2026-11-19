import numpy as np
import pandas as pd
from scipy import signal

def calc_wave_dir_puv(p_or_eta, u_east, v_north, fs=2.0, nperseg=256, fmin=0.04, fmax=0.5):
    """
    PUV 法計算波向（回傳「波浪來向」0~360 度：0=N, 90=E, 180=S, 270=W）
    """
    # 補齊偶發 NaN 並扣除線性趨勢
    eta = signal.detrend(pd.Series(p_or_eta).interpolate(limit_direction='both').values)
    u   = signal.detrend(pd.Series(u_east).interpolate(limit_direction='both').values)
    v   = signal.detrend(pd.Series(v_north).interpolate(limit_direction='both').values)

    # 計算自功率譜 (PSD) 與交叉功率譜 (CSD)
    freqs, S_eta = signal.welch(eta, fs=fs, nperseg=nperseg)
    _, S_u       = signal.welch(u, fs=fs, nperseg=nperseg)
    _, S_v       = signal.welch(v, fs=fs, nperseg=nperseg)
    _, P_eu      = signal.csd(eta, u, fs=fs, nperseg=nperseg)
    _, P_ev      = signal.csd(eta, v, fs=fs, nperseg=nperseg)

    # 限制在有效波浪頻段（水深 ~18-20m 下，超過 0.5 Hz 的流速訊號已衰減殆盡，設 0.5 Hz 較穩）
    mask = (freqs >= fmin) & (freqs <= fmax)
    C_eu = np.real(P_eu[mask])  # East 同相譜
    C_ev = np.real(P_ev[mask])  # North 同相譜
    S_band = S_eta[mask]

    # 1. 尖峰波向 Dir_peak（在最大能量頻率 fp 處的波向）
    idx_p = np.argmax(S_band)
    # 負號是因為：波峰下水質點朝「去向」流，加負號即轉為「波浪來向」
    dir_peak = (np.rad2deg(np.arctan2(-C_eu[idx_p], -C_ev[idx_p]))) % 360.0

    # 2. 能量加權平均波向 Dir_mean（標準一階傅立葉係數 a1, b1）
    denom = np.sqrt(S_band * (S_u[mask] + S_v[mask]))
    a1 = np.divide(C_ev, denom, out=np.zeros_like(C_ev), where=denom > 0)
    b1 = np.divide(C_eu, denom, out=np.zeros_like(C_eu), where=denom > 0)

    a1_bar = np.sum(a1 * S_band)
    b1_bar = np.sum(b1 * S_band)
    dir_mean = (np.rad2deg(np.arctan2(-b1_bar, -a1_bar))) % 360.0

    return dir_mean, dir_peak

