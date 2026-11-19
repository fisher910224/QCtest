from datetime import timedelta
import numpy as np
import pandas as pd
from numpy.lib.stride_tricks import sliding_window_view


def _to_hours(val):
    """將 numeric (小時) 或 timedelta / pd.Timedelta 轉為浮點數小時。"""
    if isinstance(val, (timedelta, pd.Timedelta, np.timedelta64)):
        return pd.Timedelta(val).total_seconds() / 3600.0
    return float(val)


def _to_datetime_index(input_time):
    """將 datetime 序列或 MATLAB datenum 數值序列轉為 pd.DatetimeIndex。"""
    if isinstance(input_time, pd.DatetimeIndex):
        return input_time

    arr = np.asarray(input_time)
    if np.issubdtype(arr.dtype, np.number):
        # MATLAB datenum 基準日轉換 (datenum 719529 = 1970-01-01)
        return pd.to_datetime(arr.ravel() - 719529.0, unit="D")
    return pd.to_datetime(arr.ravel())


def _movstd_backward(arr, window_size):
    """
    模擬 MATLAB: movstd(arr, [window_size-1, 0], 'omitnan')
    使用樣本標準差 (ddof=1)；若視窗內僅有 1 筆非 NaN 資料，回傳 0.0（與 MATLAB 一致）。
    """
    s = pd.Series(arr)
    rolling = s.rolling(window=window_size, min_periods=1)
    sd = rolling.std(ddof=1).to_numpy(copy=True)
    cnt = rolling.count().to_numpy()
    sd[cnt == 1] = 0.0
    return sd


def _is_on(opt):
    """支援 bool (True/False) 或字串 ('on'/'off')。"""
    if isinstance(opt, str):
        val = opt.strip().lower()
        if val == "on":
            return True
        if val == "off":
            return False
        raise ValueError(f"Option 必須為 'on'/'off' 或 bool，收到: {opt}")
    return bool(opt)


def qc_test(
    input_time,
    input_item,
    samplingrate,
    qc_settings,
    *,
    test1=False,
    test2=False,
    test3=False,
    test4=False,
    test5=False,
    test6=False,
    test7=False,
    test8=False,
    test9=False,
    test10=False,
    test11=False,
):
    """
    QARTOD 品質管制主函式

    Parameters
    ----------
    input_time : array-like
        時間序列 (datetime, str, 或 MATLAB datenum)
    input_item : array-like
        觀測數據序列
    samplingrate : float or timedelta
        取樣間隔 (小時數或 timedelta)
    qc_settings : dict
        包含各測試參數門檻值的字典
    test1 ~ test11 : bool or {'on', 'off'}
        是否啟用對應的測試項目

    Returns
    -------
    flags : ndarray of shape (N, 11)
        各項測試的獨立旗標矩陣
    flags_total : ndarray of shape (N,)
        綜合總旗標 (1: Pass, 2: Not Evaluated, 3: Suspect, 4: Fail, 9: Missing)
    """
    arr = np.asarray(input_item, dtype=float).ravel()
    n = len(arr)
    sr_hours = _to_hours(samplingrate)

    def _run_or_skip(enabled, name, func, *args):
        if _is_on(enabled):
            f = func(*args)
            pass_rate = (np.sum(f <= 2) / n * 100.0) if n > 0 else 0.0
            print(f"{name} complete! Passing rate: {pass_rate:.2f}%")
            return f
        else:
            print(f"Jumped {name}.")
            return np.zeros(n, dtype=int)

    f1 = _run_or_skip(
        test1, "Test1", run_test1,
        input_time, sr_hours, qc_settings.get("t1_suspect"), qc_settings.get("t1_fail")
    )
    f2 = _run_or_skip(test2, "Test2", run_test2, arr)
    f3 = _run_or_skip(test3, "Test3", run_test3, arr)
    f4 = _run_or_skip(
        test4, "Test4", run_test4,
        arr, qc_settings.get("t4_sensor_range"), qc_settings.get("t4_user_range")
    )
    f5 = _run_or_skip(
        test5, "Test5", run_test5,
        input_time, arr, qc_settings.get("t5_sensor_range"), qc_settings.get("t5_user_range")
    )
    f6 = _run_or_skip(
        test6, "Test6", run_test6,
        arr, qc_settings.get("t6_threshold_low"), qc_settings.get("t6_threshold_high")
    )
    f7 = _run_or_skip(
        test7, "Test7", run_test7,
        input_time, arr, qc_settings.get("t7_n_dev"), qc_settings.get("t7_tim_dev_hours"), sr_hours
    )
    f8 = _run_or_skip(
        test8, "Test8", run_test8,
        arr, qc_settings.get("t8_rep_suspect"), qc_settings.get("t8_rep_fail"), qc_settings.get("t8_esp_val")
    )
    f9 = _run_or_skip(test9, "Test9", run_test9, arr)
    f10 = _run_or_skip(
        test10, "Test10", run_test10,
        arr, qc_settings.get("t10_n_tst"), qc_settings.get("t10_min_var_warn"), qc_settings.get("t10_min_var_fail"), sr_hours
    )
    f11 = _run_or_skip(test11, "Test11", run_test11, arr)

    flags = np.column_stack([f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11])

    # 1. 預設全為 2 (Not Evaluated / 未評估)
    flags_total = np.full(n, 2, dtype=int)

    # 2. 只要有任何一項測試通過 (1)，總旗標先設為 1 (Pass)
    flags_total[np.any(flags == 1, axis=1)] = 1

    # 3. 只要有任何一項測試判定為可疑 (3)，覆蓋為 3 (Suspect)
    flags_total[np.any(flags == 3, axis=1)] = 3

    # 4. 只要有任何一項測試判定為不良 (4)，覆蓋為 4 (Fail)
    flags_total[np.any(flags == 4, axis=1)] = 4

    # 5. 若原始數據本身是缺失 (NaN) 或有測試標記為資料遺失 (9)，覆蓋為 9 (Missing)
    flags_total[np.isnan(arr) | np.any(flags == 9, axis=1)] = 9

    return flags, flags_total


# =========================================================================
# 各項獨立測試函式 (Test1 ~ Test11)
# =========================================================================

def run_test1(input_time, samplingrate, tol_suspect, tol_fail):
    """TIME GAP TEST"""
    it = _to_datetime_index(input_time)
    tol_sus_td = pd.Timedelta(hours=_to_hours(tol_suspect))
    tol_fail_td = pd.Timedelta(hours=_to_hours(tol_fail))

    if tol_sus_td >= tol_fail_td:
        raise ValueError(
            f"Test1 Error: tol_suspect ({tol_sus_td}) cannot equal or larger than tol_fail ({tol_fail_td})."
        )

    flags = np.ones(len(it), dtype=int)
    if len(it) < 2:
        flags[pd.isna(it)] = 9
        return flags

    time_gap = pd.Series(it).diff().iloc[1:].to_numpy()
    sr = pd.Timedelta(hours=_to_hours(samplingrate))
    deviation = np.abs(time_gap - sr)

    flags[1:][deviation > tol_sus_td] = 3
    flags[1:][deviation > tol_fail_td] = 4
    flags[1:][time_gap <= pd.Timedelta(0)] = 4
    flags[pd.isna(it)] = 9

    return flags


def run_test2(input_item):
    arr = np.asarray(input_item, dtype=float).ravel()
    flags = np.ones(len(arr), dtype=int)
    flags[np.isnan(arr)] = 9
    return flags


def run_test3(input_item):
    arr = np.asarray(input_item, dtype=float).ravel()
    return np.ones(len(arr), dtype=int)


def run_test4(input_item, sensor_range, user_range):
    """GROSS RANGE TEST"""
    if user_range[0] < sensor_range[0] or user_range[1] > sensor_range[1]:
        raise ValueError("Test4 Error: user_range needs to be in range of sensor_range.")

    arr = np.asarray(input_item, dtype=float).ravel()
    flags = np.ones(len(arr), dtype=int)

    idx_suspect = (arr < user_range[0]) | (arr > user_range[1])
    flags[idx_suspect] = 3

    idx_fail = (arr < sensor_range[0]) | (arr > sensor_range[1])
    flags[idx_fail] = 4

    flags[np.isnan(arr)] = 9
    return flags


def run_test5(input_time, input_item, sensor_range, user_range):
    """MONTHLY GROSS RANGE TEST (CLIMATOLOGY TEST)"""
    s_range = np.asarray(sensor_range, dtype=float)
    u_range = np.asarray(user_range, dtype=float)

    if np.any(u_range[:, 0] < s_range[:, 0]) or np.any(u_range[:, 1] > s_range[:, 1]):
        raise ValueError("Test5 Error: At least one month's user_range is out of sensor_range.")

    it = _to_datetime_index(input_time)
    mm = it.month.to_numpy()
    arr = np.asarray(input_item, dtype=float).ravel()
    flags = np.ones(len(arr), dtype=int)

    for m in range(1, 13):
        idx_m = mm == m
        if not np.any(idx_m):
            continue

        s_min, s_max = s_range[m - 1]
        u_min, u_max = u_range[m - 1]

        current_vals = arr[idx_m]
        current_flags = np.ones(len(current_vals), dtype=int)

        current_flags[(current_vals < u_min) | (current_vals > u_max)] = 3
        current_flags[(current_vals < s_min) | (current_vals > s_max)] = 4

        flags[idx_m] = current_flags

    flags[np.isnan(arr)] = 9
    return flags


def run_test6(input_item, threshold_low, threshold_high):
    """SPIKE TEST"""
    if threshold_low >= threshold_high:
        raise ValueError("Test6 Error: threshold_low must be smaller than threshold_high.")
    if threshold_low < 0 or threshold_high < 0:
        raise ValueError("Test6 Error: Thresholds must be non-negative.")

    arr = np.asarray(input_item, dtype=float).ravel()
    n = len(arr)
    if n < 3:
        flags = np.full(n, 2, dtype=int)
        flags[np.isnan(arr)] = 9
        return flags

    flags = np.ones(n, dtype=int)

    x_target = arr[1:-1]
    x_prev = arr[:-2]
    x_next = arr[2:]

    # 計算前後兩點平均值 (忽略單邊 NaN，避免全為 NaN 時產生 RuntimeWarning)
    pair = np.column_stack([x_prev, x_next])
    valid_cnt = np.sum(~np.isnan(pair), axis=1)
    spk_ref = np.where(
        valid_cnt > 0,
        np.nansum(pair, axis=1) / np.where(valid_cnt > 0, valid_cnt, 1),
        np.nan,
    )

    diff_val = np.abs(x_target - spk_ref)
    has_nan_neighbor = np.isnan(x_prev) | np.isnan(x_next)

    flags[[0, -1]] = 2
    mid_nan_mask = np.concatenate([[False], has_nan_neighbor, [False]]) & (flags != 9)
    flags[mid_nan_mask] = 2

    mask_suspect = np.concatenate([[False], diff_val > threshold_low, [False]])
    mask_fail = np.concatenate([[False], diff_val > threshold_high, [False]])

    flags[mask_suspect] = 3
    flags[mask_fail] = 4
    flags[np.isnan(arr)] = 9
    return flags


def run_test7(input_time, input_item, n_dev, tim_dev_hours, expected_interval):
    """RATE OF CHANGE TEST"""
    it = _to_datetime_index(input_time)
    arr = np.asarray(input_item, dtype=float).ravel()
    n = len(arr)
    flags = np.ones(n, dtype=int)

    if n < 2:
        flags[:] = 2
        flags[np.isnan(arr)] = 9
        return flags

    exp_hours = _to_hours(expected_interval)
    exp_td = pd.Timedelta(hours=exp_hours)

    dv = np.diff(arr)
    dt = pd.Series(it).diff().iloc[1:].to_numpy()

    pts_in_window = max(1, int(round(tim_dev_hours / exp_hours)))
    moving_sd = _movstd_backward(dv, pts_in_window)
    time_is_valid = dt <= (exp_td * 1.5)

    abs_change = np.abs(dv)
    min_allowable_sd = 0.05  # 保底標準差
    threshold = n_dev * np.fmax(moving_sd, min_allowable_sd)

    is_suspect = (abs_change > threshold) & time_is_valid
    flags[1:][is_suspect] = 3

    flags[:min(pts_in_window, n)] = 2
    flags[np.isnan(arr)] = 9
    return flags


def run_test8(input_item, rep_cnt_suspect, rep_cnt_fail, esp_val):
    """FLAT LINE TEST"""
    if rep_cnt_suspect >= rep_cnt_fail:
        raise ValueError("Test8 Error: rep_cnt_suspect needs to be less than rep_cnt_fail.")

    arr = np.asarray(input_item, dtype=float).ravel()
    n = len(arr)
    flags = np.ones(n, dtype=int)

    if rep_cnt_suspect > 1:
        flags[:min(rep_cnt_suspect - 1, n)] = 2

    if n >= rep_cnt_suspect:
        win_s = sliding_window_view(arr, rep_cnt_suspect)
        valid_s = ~np.any(np.isnan(win_s), axis=1)
        flat_s = np.all(np.abs(win_s - arr[rep_cnt_suspect - 1:, None]) <= esp_val, axis=1)
        flags[rep_cnt_suspect - 1:][valid_s & flat_s] = 3

    if n >= rep_cnt_fail:
        win_f = sliding_window_view(arr, rep_cnt_fail)
        valid_f = ~np.any(np.isnan(win_f), axis=1)
        flat_f = np.all(np.abs(win_f - arr[rep_cnt_fail - 1:, None]) <= esp_val, axis=1)
        flags[rep_cnt_fail - 1:][valid_f & flat_f] = 4

    flags[np.isnan(arr)] = 9
    return flags


def run_test9(input_item):
    arr = np.asarray(input_item, dtype=float).ravel()
    return np.ones(len(arr), dtype=int)


def run_test10(input_item, test_duration, min_var_warn, min_var_fail, sampling_rate):
    """ATTENUATED SIGNAL TEST"""
    if min_var_warn <= min_var_fail:
        raise ValueError("Test10 Error: min_var_warn must be larger than min_var_fail.")

    arr = np.asarray(input_item, dtype=float).ravel()
    n = len(arr)
    flags = np.ones(n, dtype=int)
    flags[np.isnan(arr)] = 9

    n_tst = int(round(_to_hours(test_duration) / _to_hours(sampling_rate)))
    if n < n_tst or n_tst <= 0:
        return flags

    sd_vec = _movstd_backward(arr, n_tst)
    valid_count = (
        pd.Series(~np.isnan(arr))
        .rolling(window=n_tst, min_periods=1)
        .sum()
        .to_numpy()
    )

    evaluation_mask = valid_count >= (n_tst * 0.75)

    idx_fail = (sd_vec < min_var_fail) & evaluation_mask
    idx_suspect = (sd_vec < min_var_warn) & evaluation_mask

    idx_fail[:n_tst - 1] = False
    idx_suspect[:n_tst - 1] = False

    flags[:n_tst - 1] = 2
    flags[idx_suspect] = 3
    flags[idx_fail] = 4
    flags[np.isnan(arr)] = 9
    return flags


def run_test11(input_item):
    arr = np.asarray(input_item, dtype=float).ravel()
    return np.ones(len(arr), dtype=int)


# =========================================================================
# 預設參數設定 (對應原程式碼中的 Tide / Current / Wave 設定檔)
# =========================================================================

TD_QCsettings = {
    "t1_suspect": 1 / 60,
    "t1_fail": 5 / 60,
    "t4_sensor_range": [0, 25],
    "t4_user_range": [0, 25],
    "t5_sensor_range": np.tile([0, 25], (12, 1)),
    "t5_user_range": np.tile([0, 25], (12, 1)),
    "t6_threshold_low": 0.5,
    "t6_threshold_high": 1.0,
    "t7_n_dev": 5,
    "t7_tim_dev_hours": 12,
    "t8_rep_suspect": 3,
    "t8_rep_fail": 5,
    "t8_esp_val": 0.001,
    "t10_min_var_warn": 0.05,
    "t10_min_var_fail": 0.01,
    "t10_n_tst": 24,
}

CU_QCsettings = {
    "t1_suspect": 1 / 60,
    "t1_fail": 5 / 60,
    "t4_sensor_range": [-15, 15],
    "t4_user_range": [0, 2],
    "t5_sensor_range": np.tile([-15, 15], (12, 1)),
    "t5_user_range": np.array([
        [0, 1.1], [0, 1.1], [0, 1.1], [0, 1.1], [0, 1.1], [0, 1.2],
        [0, 1.2], [0, 1.2], [0, 1.2], [0, 1.2], [0, 1.2], [0, 1.1],
    ]),
    "t6_threshold_low": 0.6,
    "t6_threshold_high": 1.0,
    "t7_n_dev": 3,
    "t7_tim_dev_hours": 8,
    "t8_rep_suspect": 3,
    "t8_rep_fail": 5,
    "t8_esp_val": 0.001,
    "t10_min_var_warn": 0.045,
    "t10_min_var_fail": 0.005,
    "t10_n_tst": 12,
}

CD_QCsettings = {
    "t1_suspect": 1 / 60,
    "t1_fail": 5 / 60,
    "t4_sensor_range": [0, 360],
    "t4_user_range": [0, 360],
    "t5_sensor_range": np.tile([0, 360], (12, 1)),
    "t5_user_range": np.tile([0, 360], (12, 1)),
    "t6_threshold_low": 0.6,
    "t6_threshold_high": 1.0,
    "t7_n_dev": 3,
    "t7_tim_dev_hours": 8,
    "t8_rep_suspect": 3,
    "t8_rep_fail": 5,
    "t8_esp_val": 0.01,
    "t10_min_var_warn": 0.045,
    "t10_min_var_fail": 0.005,
    "t10_n_tst": 12,
}

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


# =========================================================================
# 使用範例
# =========================================================================
if __name__ == "__main__":
    # 建立模擬資料 (每小時 1 筆，共 48 小時)
    times = pd.date_range("2026-01-01", periods=48, freq="1h")
    tide = 2.0 + 1.5 * np.sin(np.linspace(0, 4 * np.pi, 48))
    tide[10] = 9.0   # 人為 Spike
    tide[20:26] = 2.0  # 人為 Flat line

    flags, flags_total = qc_test(
        input_time=times,
        input_item=tide,
        samplingrate=1.0,  # 小時 (亦可傳入 pd.Timedelta(hours=1))
        qc_settings=TD_QCsettings,
        test1=True,
        test6=True,
        test8=True,
    )
    print("Total flags:", flags_total)