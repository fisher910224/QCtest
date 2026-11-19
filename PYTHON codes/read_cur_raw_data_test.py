import pandas as pd
import numpy as np
import glob

dd = glob.glob(r'C:\Users\adm\Desktop\Xingda\107884-ascii\*A0_avgd.csv')
raw = {}
for i in dd:
    if 'avgdA0' not in i:
        print(i)
        csv_data = pd.read_csv(i, delimiter=';')
        # print(csv_data["DateTime"][0:5])

raw_time = pd.to_datetime(csv_data["DateTime"])
raw_pres = csv_data["Pressure"]
idx = (raw_pres > 15) & (raw_time >= pd.to_datetime("2026-04-18 12:00:00")) & (raw_time < pd.to_datetime("2026-06-06 08:00:00"))

idx_st = np.where(idx)[0][0]

raw["time"] = raw_time[idx]
raw["pres"] = raw_pres[idx]
raw["temp"] = csv_data["Temperature"][idx]
raw["u"] = csv_data[["East#2", "East#7", "East#13"]][idx]
raw["v"] = csv_data[["North#2", "North#7", "North#13"]][idx]
# print(raw["time"].head())
# print(raw["u"].head())


ddir = np.arctan2(raw["u"].to_numpy(), raw["v"].to_numpy())
ddir = np.degrees(ddir+360)%360
# print(ddir[0:5])
cur = np.sqrt(raw["u"].to_numpy()**2 + raw["v"].to_numpy()**2)

raw["dir"] = pd.DataFrame(ddir, columns=["dir1", "dir2", "dir3"], index=raw["time"].index)
raw["cur"] = pd.DataFrame(cur, columns=["cur1", "cur2", "cur3"], index=raw["time"].index)
# print(raw["dir"].head())

for i in raw:
    print(i, type(raw[i]))
    # print()
raw_table = pd.concat([raw[i] for i in raw], axis=1, ignore_index=False)
print(raw_table.head())

raw_table.to_csv(r'C:\Users\adm\Desktop\Xingda\S107884A005_NSYSU_SINDA_avgd_cur.csv', index=False, float_format='%.4f')



