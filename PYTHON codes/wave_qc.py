import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import glob
from qc_test import qc_test

dd = glob.glob(r'C:\Users\adm\Desktop\Xingda\Ocean*wave.csv')
# print(dd)
df = pd.read_csv(dd[0], parse_dates=['time'])
print(df.head())

dday = df['time']
Hs = df['Height_Hm0']
Tmean = df['Period_Tm02']
Tp = df['Period_Tp']
Dir = df['Direction_MeanDir']

WV_QCsettings = {
    "t1_suspect": 1 / 60,
    "t1_fail": 5 / 60,
    "t4_sensor_range": [0, 40],
    "t4_user_range": [0, 10],
    "t5_sensor_range": np.tile([0, 40], (12, 1)),
    "t5_user_range": np.tile([0, 10], (12, 1)),
    "t6_threshold_low": 1.0,
    "t6_threshold_high": 2.0,
    "t7_n_dev": 5,
    "t7_tim_dev_hours": 8,
    "t8_rep_suspect": 3,
    "t8_rep_fail": 5,
    "t8_esp_val": 0.01,
    "t10_min_var_warn": 0.01,
    "t10_min_var_fail": 0.005,
    "t10_n_tst": 12,
}

TP_QCsettings = {
    "t1_suspect": 1 / 60,
    "t1_fail": 5 / 60,
    "t4_sensor_range": [0, 30],
    "t4_user_range": [0, 20],
    "t5_sensor_range": np.tile([0, 30], (12, 1)),
    "t5_user_range": np.tile([0, 20], (12, 1)),
    "t6_threshold_low": 1.0,
    "t6_threshold_high": 2.0,
    "t7_n_dev": 5,
    "t7_tim_dev_hours": 8,
    "t8_rep_suspect": 3,
    "t8_rep_fail": 5,
    "t8_esp_val": 0.01,
    "t10_min_var_warn": 1 / 10,
    "t10_min_var_fail": 1 / 20,
    "t10_n_tst": 12,
}

WVD_QCsettings = {
    "t1_suspect": 1 / 60,
    "t1_fail": 5 / 60,
    "t4_sensor_range": [0, 360],
    "t4_user_range": [0, 360],
    "t5_sensor_range": np.tile([0, 360], (12, 1)),
    "t5_user_range": np.tile([0, 360], (12, 1)),
    "t6_threshold_low": 1.0,
    "t6_threshold_high": 2.0,
    "t7_n_dev": 5,
    "t7_tim_dev_hours": 8,
    "t8_rep_suspect": 3,
    "t8_rep_fail": 5,
    "t8_esp_val": 0.01,
    "t10_min_var_warn": 1 / 10,
    "t10_min_var_fail": 1 / 20,
    "t10_n_tst": 12,
}

flags, flags_total = qc_test(input_time=dday, input_item=Hs,
                             samplingrate=1.0, qc_settings=WV_QCsettings, 
                             test1=True, test2=True, test3=False, test4=True, test5=True, test6=True,
                             test7=True, test8=True, test9=False, test10=True, test11=False)
flags_head = [f"Test{i}" for i in range(1, 12)]
flags_table = pd.DataFrame(flags, columns=flags_head)
flags_table.to_csv(r'C:\Users\adm\Desktop\Xingda\Hs_qc_flags.csv', index=False, float_format='%d')

Hs_flag = flags_total.copy()
Hs_qced = Hs.copy()
Hs_sus = Hs.copy()
Hs_sus[flags_total != 3] = np.nan
Hs_qced[flags_total > 3] = np.nan
# print(flags_total)

flags, flags_total = qc_test(input_time=dday, input_item=Tmean,
                             samplingrate=1.0, qc_settings=TP_QCsettings, 
                             test1=True, test2=True, test3=False, test4=True, test5=True, test6=True,
                             test7=True, test8=True, test9=False, test10=True, test11=False)
flags_head = [f"Test{i}" for i in range(1, 12)]
flags_table = pd.DataFrame(flags, columns=flags_head)
flags_table.to_csv(r'C:\Users\adm\Desktop\Xingda\Tmean_qc_flags.csv', index=False, float_format='%d')
Tmean_qced = Tmean.copy()
Tmean_sus = Tmean.copy()
Tmean_sus[flags_total != 3] = np.nan
Tmean_qced[flags_total > 3] = np.nan


flags, flags_total = qc_test(input_time=dday, input_item=Tp,
                             samplingrate=1.0, qc_settings=TP_QCsettings, 
                             test1=True, test2=True, test3=False, test4=True, test5=True, test6=True,
                             test7=True, test8=True, test9=False, test10=True, test11=False)
flags_head = [f"Test{i}" for i in range(1, 12)]
flags_table = pd.DataFrame(flags, columns=flags_head)
flags_table.to_csv(r'C:\Users\adm\Desktop\Xingda\Tp_qc_flags.csv', index=False, float_format='%d')
Tp_qced = Tp.copy()
Tp_sus = Tp.copy()
Tp_sus[flags_total != 3] = np.nan
Tp_qced[flags_total > 3] = np.nan


flags, flags_total = qc_test(input_time=dday, input_item=Dir,
                             samplingrate=1.0, qc_settings=WVD_QCsettings, 
                             test1=True, test2=True, test3=False, test4=True, test5=True, test6=False,
                             test7=False, test8=False, test9=False, test10=False, test11=False)
flags_head = [f"Test{i}" for i in range(1, 12)]
flags_table = pd.DataFrame(flags, columns=flags_head)
flags_table.to_csv(r'C:\Users\adm\Desktop\Xingda\Dir_qc_flags.csv', index=False, float_format='%d')
Dir_qced = Dir.copy()
Dir_sus = Dir.copy()
Dir_sus[(flags_total != 3) & (Hs_flag != 3)] = np.nan
Dir_qced[(flags_total > 3) & (Hs_flag > 3)] = np.nan



df_qced = pd.DataFrame({
    "time": dday, 
    "Hs": Hs_qced, 
    "Tmean": Tmean_qced, 
    "Tp": Tp_qced, 
    "Dir": Dir_qced
})
df_qced.to_csv(r'C:\Users\adm\Desktop\Xingda\QCed_Wave_data.csv', index=False, float_format='%.4f')


# t_start = dday.min().floor('D')
# t_end   = dday.max().ceil('D')
# ticks = pd.date_range(start=t_start, end=t_end, freq='4D')

# fig, ax = plt.subplots(4, 1, figsize=(10, 10), sharex=True)
# ax[0].plot(dday, Hs, linestyle='-', color='r', label='Fail')
# ax[0].plot(dday, Hs_qced, linestyle='-', color='k', label='Pass')
# ax[0].scatter(dday, Hs_sus, color='orange', s=5, label='Suspect')
# ax[0].set_title('Hs')
# ax[0].set_ylim(0, 2)
# ax[0].set_ylabel('(m)')

# ax[1].plot(dday, Tmean, linestyle='-', color='r', label='Fail')
# ax[1].plot(dday, Tmean_qced, linestyle='-', color='k', label='Pass')
# ax[1].scatter(dday, Tmean_sus, color='orange', s=5, label='Suspect')
# ax[1].set_title('Tmean')
# ax[1].set_ylabel('(sec)')

# ax[2].plot(dday, Tp, linestyle='-', color='r', label='Fail')
# ax[2].plot(dday, Tp_qced, linestyle='-', color='k', label='Pass')
# ax[2].scatter(dday, Tp_sus, color='orange', s=5, label='Suspect')
# ax[2].set_title('Tp')
# ax[2].set_ylim(0, 20)
# ax[2].set_ylabel('(sec)')

# ax[3].scatter(dday, Dir, color='r', s=5, label='Fail')
# ax[3].scatter(dday, Dir_qced, color='k', s=5, label='Pass')
# ax[3].scatter(dday, Dir_sus, color='orange', s=5, label='Suspect')
# ax[3].set_title('Dir')
# ax[3].set_ylabel('(degree)')
# ax[3].set_ylim(0, 360)
# ax[3].set_yticks(np.arange(0, 361, 90))

# for i in range(0, 4):
#     ax[i].set_xlim(t_start, t_end)
#     ax[i].set_xticks(ticks)
#     ax[i].xaxis.set_minor_locator(mdates.DayLocator(interval=1))
#     ax[i].xaxis.set_major_formatter(mdates.DateFormatter("%m/%d"))
#     ax[i].grid()
#     ax[i].legend()
    
# plt.show()
# fig.savefig(r'C:\Users\adm\Desktop\Xingda\wave_qc.png', dpi=300, bbox_inches='tight')
# plt.show()




# t_start = dday.min().floor('D')
# t_end   = dday.max().ceil('D')
# ticks = pd.date_range(start=t_start, end=t_end, freq='4D')

# fig, ax = plt.subplots(4, 1, figsize=(10, 10), sharex=True)

# ax[0].plot(dday, Hs, linestyle='-', color='k')
# ax[0].set_title('Hs')
# ax[0].set_ylim(0, 2)
# ax[0].set_ylabel('(m)')

# ax[1].plot(dday, Tmean, linestyle='-', color='k')
# ax[1].set_title('Tmean')
# ax[1].set_ylabel('(sec)')

# ax[2].plot(dday, Tp, linestyle='-', color='k')
# ax[2].set_title('Tp')
# ax[2].set_ylim(0, 20)
# ax[2].set_ylabel('(sec)')

# ax[3].scatter(dday, Dir, color='k', s=5)
# ax[3].set_title('Dir')
# ax[3].set_ylabel('(degree)')
# ax[3].set_ylim(0, 360)
# ax[3].set_yticks(np.arange(0, 361, 90))

# for i in range(0, 4):
#     ax[i].set_xlim(t_start, t_end)
#     ax[i].set_xticks(ticks)
#     ax[i].xaxis.set_minor_locator(mdates.DayLocator(interval=1))
#     ax[i].xaxis.set_major_formatter(mdates.DateFormatter("%m/%d"))
#     ax[i].grid()

# fig.savefig(r'C:\Users\adm\Desktop\Xingda\S107884A005_NSYSU_SINDA_wave_analysis.png', dpi=300, bbox_inches='tight')
# # plt.show()