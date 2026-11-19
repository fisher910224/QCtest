import pandas as pd
import numpy as np
import glob
from scipy import signal
from scipy.integrate import trapezoid
from calc_wave_dir_puv import calc_wave_dir_puv

dd = glob.glob(r'C:\Users\adm\Desktop\Xingda\107884-ascii\*B0*.csv')
raw = {}
csv_data = {}
counting = 0
cols = ["DateTime", "EnsembleCount", "Pitch", "Roll", "Pressure", 
        "AltimeterDistanceAST", "AltimeterQualityAST", "AltimeterPressure", 
        "East#13", "North#13"]

for i in dd:
    if 'RA' not in i:
        counting += 1
        print(i)
        csv_data[f"{counting}"] = pd.read_csv(i, delimiter=';', usecols=cols)
        print(csv_data[f"{counting}"].columns.to_list())
        # print(csv_data[f"{counting}"]["DateTime"][0:5])

raw_big_data = pd.concat([csv_data[i] for i in csv_data], axis=0, ignore_index=True)
# print(raw_big_data.head(), raw_big_data.shape)

raw_time = pd.to_datetime(raw_big_data["DateTime"])
idx = (raw_time >= pd.to_datetime("2026-04-18 12:00:00")) & (raw_time < pd.to_datetime("2026-06-06 08:00:00"))
raw_time = raw_time[idx]
raw_pitch = raw_big_data["Pitch"][idx]
raw_roll = raw_big_data["Roll"][idx]
raw_pres = raw_big_data["Pressure"][idx]
raw_ast_dist = raw_big_data["AltimeterDistanceAST"][idx]

ig = raw_big_data["EnsembleCount"][idx] == 1
n_burst = max(raw_big_data["EnsembleCount"][idx])
# print(ig, n_burst)

# raw["time"] = raw_time[ig]
# print(raw["time"].head())
# raw["ast_dist"] = raw_ast_dist
# print(raw["ast_dist"].head(), raw["ast_dist"].shape)

raw["burst_id"] = (raw_big_data["EnsembleCount"][idx] == 1).cumsum()
# print(raw["burst_id"].head())
# print(raw["u"].head())

results = []
fs = 2.0

for bid, grp in raw_big_data[idx].groupby(raw["burst_id"]):
    if len(grp) == n_burst:
        
        pitch_rad = np.deg2rad(grp["Pitch"].values)
        roll_rad = np.deg2rad(grp["Roll"].values)
        ast = grp['AltimeterDistanceAST'].values * np.cos(pitch_rad) * np.cos(roll_rad)
        eta = signal.detrend(ast, type='linear')
        freqs, psd = signal.welch(eta, fs=fs, nperseg=256)
        mask = (freqs >= 0.04) & (freqs <= 1.0)
        m0 = np.sum(psd[mask]) * (freqs[1] - freqs[0])
        m2 = trapezoid((freqs[mask] ** 2) * psd[mask], freqs[mask])
        Tm02 = np.sqrt(m0 / m2)                  # 頻譜平均週期
        Tp = 1.0 / freqs[mask][np.argmax(psd[mask])]  # 尖峰週期 (Peak Period)
        Hm0 = 4.0 * np.sqrt(m0)
        dir_mean, dir_peak = calc_wave_dir_puv(
            # grp['Pressure'].values,
            grp['AltimeterDistanceAST'].values,
            grp['East#13'].values,
            grp['North#13'].values,
            fs=2.0
        )
        results.append({
            'time': pd.to_datetime(grp["DateTime"].values[0]),
            'burst_id': bid,
            'Hm0': Hm0,
            'Tm02': Tm02,
            'Tp': Tp,
            'Dir': dir_mean,
            'dir_peak': dir_peak
        })
res_df = pd.DataFrame(results)
res_df.to_csv(r'C:\Users\adm\Desktop\Xingda\S107884A005_NSYSU_SINDA_calculated_wave.csv', index=False, float_format='%.4f')
# print(res_df.head())



