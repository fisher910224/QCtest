import pandas as pd
import xarray as xr
import netCDF4 as nc
import matplotlib.pyplot as plt

file_path = r"C:\Users\adm\Desktop\Xingda\107884-ascii\processing_wave\Exported Data\S107884A005_NSYSU_SINDA\Burst.WAVES.nc"
# with nc.Dataset(r"C:\Users\adm\Desktop\Xingda\107884-ascii\processing_wave\Exported Data\S107884A005_NSYSU_SINDA\Burst.WAVES.nc") as f:
#     print("Roots variables:", list(f.variables.keys()))
#     print("Groups:", list(f.groups.keys()))

# def show_nc_tree(group, path=""):
#     if group.variables:
#         print(f"📁 群組路徑: {path or '/'}")
#         for name, var in group.variables.items():
#             print(f"   - {name}: shape={var.shape}, dims={var.dimensions}")
#     for sub_name, sub_group in group.groups.items():
#         show_nc_tree(sub_group, f"{path}/{sub_name}")

# with nc.Dataset(file_path) as f:
#     show_nc_tree(f)

# dd = nc.Dataset(file_path, group="/Data/Waves")
# ds = xr.open_dataset("你的檔案路徑.nc", group="實際的群組名稱")
ds = xr.open_dataset(file_path, group='/Data/Waves')
# print(ds)
# print("Time 範例:", ds["time"].values[:3])
# print("Time 屬性:", ds["time"].attrs)
# raw_time = pd.to_datetime(ds["time"])

cols = ["time", 
    # 波高 (m)
    "Height_Hm0", "Height_H3", "Height_H10", "Height_Hmax", "Height_Hmean",
    # 週期 (s)
    "Period_Tp", "Period_Tm02", "Period_Tz", "Period_T3",
    # 波向 (deg, 波浪來向)
    "Direction_DirTp", "Direction_MeanDir", "Direction_SprTp",
    # 水壓、海流與溫度
    "MeanPressureandDistance_BurstPressure", "CurrentSpeed", "CurrentDirection", "Temperature",
    # 品管指標 (QA/QC)
    "SurfaceDetection_None", "SurfaceDetection_Bad",
    "Status_Missing_Data", "Status_AST_Loss_High", "Status_Unreasonable_Estimate",
    "Status_No_Pressure", "Status_High_Tilt"
]

df = ds[cols].to_dataframe()
df.insert(0, "time", df.index)

print("\n品管欄位統計：")
print(df[["SurfaceDetection_None", "SurfaceDetection_Bad",
          "Status_AST_Loss_High", "Status_Unreasonable_Estimate"]].describe())


bad_mask = (
    (df["SurfaceDetection_Bad"] > 5) |          # 壞點比例 > 5%
    (df["SurfaceDetection_None"] > 5) |         # 漏測比例 > 5%
    (df["Status_Missing_Data"] != 0) |
    (df["Status_AST_Loss_High"] != 0) |
    (df["Status_Unreasonable_Estimate"] != 0)
)

print(f"\n共標記剔除 {bad_mask.sum()} 筆異常時段（佔全部 {len(df)} 筆）")

df_clean = df.copy()
wave_cols = [c for c in cols if c.startswith(("Height_", "Period_", "Direction_"))]
df_clean.loc[bad_mask, wave_cols] = float("nan")

df_clean.to_csv(r'C:\Users\adm\Desktop\Xingda\OceanContour_and_simpleQC_wave.csv', 
                index=False, 
                float_format='%.4f', 
                encoding="utf-8-sig", 
                date_format="%Y/%m/%d %H:%M:%S")

# 4. 畫圖對比（原始 vs 過濾後）
fig, axes = plt.subplots(2, 1, figsize=(12, 6), sharex=True)

df["Height_Hm0"].plot(ax=axes[0], color="lightgray", label="Raw Hm0")
df_clean["Height_Hm0"].plot(ax=axes[0], color="tab:blue", label="Clean Hm0")
axes[0].set_ylabel("Hm0 (m)")
axes[0].set_title("Significant Wave Height (Hm0)")
axes[0].legend()
axes[0].grid(True, alpha=0.3)

df["Period_Tp"].plot(ax=axes[1], color="lightgray", label="Raw Tp")
df_clean["Period_Tp"].plot(ax=axes[1], color="tab:orange", label="Clean Tp")
axes[1].set_ylabel("Tp (s)")
axes[1].set_title("Peak Period (Tp)")
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()


