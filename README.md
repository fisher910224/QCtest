# QC_TEST — 海洋觀測資料品質管制 (QARTOD QC)

`QC_TEST` 是一個基於 **IOOS QARTOD**（Quality Assurance / Quality Control of Real-Time Oceanographic Data）標準所撰寫的 MATLAB 品質管制函式，適用於潮位、海流（流速/流向）、波浪（波高/週期/波向）等時間序列觀測資料的自動化品管檢核。

---

## 目錄
- [系統需求](#系統需求)
- [函式語法與參數說明](#函式語法與參數說明)
- [QC 旗標定義 (Flags)](#qc-旗標定義-flags)
- [測試項目說明與設定檔結構 (`QC_settings`)](#測試項目說明與設定檔結構-qc_settings)
- [使用範例](#使用範例)
- [注意事項與待修正細節](#注意事項與待修正細節)

---

## 系統需求
* MATLAB R2019b 或以上版本（因函式內使用 `arguments` 參數驗證區塊及 Name-Value 選項語法）。

---

## 函式語法與參數說明

```matlab
[flags, flags_total] = QC_TEST(input_time, input_item, samplingrate, QC_settings, Options)
```

### 輸入參數 (Inputs)

| 參數名稱 | 型別 | 說明 |
| :--- | :--- | :--- |
| `input_time` | `datetime` 或 `double` (`datenum`) | 觀測資料的時間序列。 |
| `input_item` | `double` 向量 | 觀測數值資料序列（**強烈建議傳入 $N \times 1$ 行向量**）。 |
| `samplingrate` | `double` 或 `duration` | 資料的預期採樣時間間隔。若為數值，單位為 **小時 (Hours)**（例如 10 分鐘資料可輸入 `1/6` 或 `minutes(10)`）。 |
| `QC_settings` | `struct` | 包含各項測試門檻與參數的設定結構體（詳見下方說明）。 |
| `Options` | Name-Value 參數 | 用於個別開啟 (`"on"`) 或關閉 (`"off"`) `Test1` ~ `Test11`。 |

#### `Options` 預設開關狀態
* **預設開啟 (`"on"`)**：`Test1`, `Test4`, `Test5`, `Test6`, `Test7`, `Test8`, `Test10`
* **預設關閉 (`"off"`)**：`Test2`, `Test3`, `Test9`, `Test11` *(註：目前為預留/佔位函式，尚未實作完整邏輯)*

---

### 輸出參數 (Outputs)

| 參數名稱 | 維度 | 說明 |
| :--- | :--- | :--- |
| `flags` | $N \times 11$ 矩陣 | 每一欄分別對應 `Test1` 至 `Test11` 的個別檢測旗標。若該項測試設為 `"off"`，對應欄位數值為 `0`。 |
| `flags_total` | $N \times 1$ 向量 | 綜合所有已執行測試後的最終品管旗標。 |

---

## QC 旗標定義 (Flags)

本程式採用 QARTOD 標準旗標編碼：

| 旗標值 | 狀態名稱 | 說明 |
| :---: | :--- | :--- |
| **`1`** | **Pass (通過)** | 資料通過所有已啟用的品管測試。 |
| **`2`** | **Not Evaluated (未評估)** | 資料位於滑動視窗邊界（如首尾點或起算點數不足），或無任何測試啟用/可評估。 |
| **`3`** | **Suspect (可疑)** | 數值異常或超出使用者設定的合理範圍，建議人工覆核。 |
| **`4`** | **Fail (不良/失敗)** | 資料確定錯誤或超出儀器物理極限。 |
| **`9`** | **Missing (遺失)** | 原始資料為 `NaN`（或時間序列為 `NaT`）。 |

### `flags_total` 彙整優先順序
當多項測試同時執行時，總旗標的覆蓋優先順序由高至低為：
> **`9 (Missing)` > `4 (Fail)` > `3 (Suspect)` > `1 (Pass)` > `2 (Not Evaluated)`**

---

## 測試項目說明與設定檔結構 (`QC_settings`)

`QC_settings` 結構體需依據開啟的測試項目提供對應欄位（程式註解中已內建 **潮汐 `TD`**、**流速 `CU`**、**流向 `CD`**、**波高 `WV`**、**波週期 `TP`**、**波向 `WVD`** 等參數範本可供參考）：

### 1. `Test1`：Time Gap Test（時間間隔測試）
檢查相鄰資料點的時間差與 `samplingrate` 之偏差。若時間差為負或重複（`time_gap <= 0`）直接判定為 `4`。
* `t1_suspect`：可疑容許誤差（單位：小時或 `duration`，需 `< t1_fail`）。
* `t1_fail`：失敗容許誤差（單位：小時或 `duration`）。

### 2. `Test4`：Gross Range Test（全距範圍測試）
檢查資料是否超出儀器感測器極限或物理合理範圍。
* `t4_sensor_range`：`[min, max]` 感測器量測極限，超出標記為 `4`。
* `t4_user_range`：`[min, max]` 使用者定義合理範圍（必須在 `t4_sensor_range` 內），超出標記為 `3`。

### 3. `Test5`：Monthly Gross Range / Climatology Test（月氣候態範圍測試）
依據資料的月份（1–12 月），分別套用該月的範圍門檻。
* `t5_sensor_range`：$12 \times 2$ 矩陣，每列為 `[min, max]`，超出標記為 `4`。
* `t5_user_range`：$12 \times 2$ 矩陣，每列為 `[min, max]`（須包含於對應月份的 `t5_sensor_range` 內），超出標記為 `3`。

### 4. `Test6`：Spike Test（突波測試）
計算每個點與前後鄰近兩點平均值之絕對差：$\left| x_i - \text{mean}(x_{i-1}, x_{i+1}) \right|$。首尾兩點或前後任一點為 `NaN` 時標記為 `2`。
* `t6_threshold_low`：可疑門檻值（非負數，需 `< t6_threshold_high`），超過標記為 `3`。
* `t6_threshold_high`：失敗門檻值，超過標記為 `4`。

### 5. `Test7`：Rate of Change Test（變化率測試）
計算相鄰兩點的變化量 `|dv|` 是否超過「滑動視窗標準差 $\times$ `n_dev`」（設有最小保底標準差 `0.05`）。僅在相鄰時間間隔 $\le 1.5 \times \text{expected\_interval}$ 時判定，超過門檻標記為 `3`；視窗建立前段資料標記為 `2`。
* `t7_n_dev`：標準差倍數門檻（例如 `3` 或 `5`）。
* `t7_tim_dev_hours`：滑動標準差的視窗時間長度（單位：小時）。

### 6. `Test8`：Flat Line Test（平線／定值卡住測試）
檢查連續資料與當前數值之絕對差是否皆 $\le$ `t8_esp_val`（表示感測器訊號卡住不動）。若視窗內含 `NaN` 則不判定。
* `t8_rep_suspect`：觸發 `3 (Suspect)` 的連續重複點數（需 `< t8_rep_fail`）。
* `t8_rep_fail`：觸發 `4 (Fail)` 的連續重複點數。
* `t8_esp_val`：數值變動的容許誤差（Tolerance）。

### 7. `Test10`：Attenuated Signal Test（訊號衰減測試）
檢查滑動視窗內的資料移動標準差（`movstd`）是否過低。為避免因大量缺測造成標準差偏低而誤判，僅在視窗內有效資料（非 `NaN`）比例 **$\ge 75\%$** 時才進行評估。
* `t10_n_tst`：評估視窗的**時間長度**（需與 `samplingrate` 單位一致，如均為小時）。
* `t10_min_var_warn`：可疑標準差下限（需 `> t10_min_var_fail`），低於此值標記為 `3`。
* `t10_min_var_fail`：失敗標準差下限，低於此值標記為 `4`。

### 8. `Test2`, `Test3`, `Test9`, `Test11`（預留測試）
目前尚未實作完整演算法（`Test2` 僅標記 `NaN` 為 `9`、其餘為 `1`；`Test3`, `Test9`, `Test11` 皆回傳 `1`），預設為 `"off"`。

---

## 使用範例

```matlab
% 1. 準備時間與觀測資料 (10 分鐘一筆，共 100 筆)
input_time = datetime(2026, 1, 1, 0, 0, 0) + minutes(0:10:990)';
input_item = 1.5 + 0.5 * sin((1:100)' / 10);
input_item(30) = 8.0; % 加入一個突波測試
samplingrate = minutes(10); % 亦可直接傳入數值 10/60

% 2. 建立設定檔 (以波高 WV 為例)
WV_QCsettings.t1_suspect = 1/60;
WV_QCsettings.t1_fail = 5/60;
WV_QCsettings.t4_sensor_range = [0 40];
WV_QCsettings.t4_user_range = [0 10];
WV_QCsettings.t5_sensor_range = repmat(WV_QCsettings.t4_sensor_range, 12, 1);
WV_QCsettings.t5_user_range = repmat(WV_QCsettings.t4_user_range, 12, 1);
WV_QCsettings.t6_threshold_low = 1.0;
WV_QCsettings.t6_threshold_high = 2.0;
WV_QCsettings.t7_n_dev = 5;
WV_QCsettings.t7_tim_dev_hours = 8;
WV_QCsettings.t8_rep_suspect = 3;
WV_QCsettings.t8_rep_fail = 5;
WV_QCsettings.t8_esp_val = 0.01;
WV_QCsettings.t10_min_var_warn = 0.01;
WV_QCsettings.t10_min_var_fail = 0.005;
WV_QCsettings.t10_n_tst = 12; % 12 小時視窗

% 3. 執行 QC_TEST (使用預設開啟項目)
[flags, flags_total] = QC_TEST(input_time, input_item, samplingrate, WV_QCsettings);

% 4. 若需關閉特定測試 (例如關閉 Test5 與 Test10)
[flags_custom, flags_total_custom] = QC_TEST(input_time, input_item, samplingrate, WV_QCsettings, ...
    "Test5", "off", "Test10", "off");
```

---

## 注意事項與待修正細節

使用或維護目前版本的程式碼時，建議留意以下幾點：

1. **輸入資料維度**：
   各子測試內部皆會將 `input_item` 轉為行向量 `input_item(:)`，但主程式在某項測試為 `"off"` 時會建立 `zeros(size(input_item))`。若傳入 $1 \times N$ 的列向量且同時有開啟與關閉的測試，合併 `flags = [f1, f2, ...]` 時會發生矩陣維度不一致的錯誤。請確保傳入的 `input_item` 為 **$N \times 1$ 行向量**。
2. **`Test7` 時間型別比較問題**：
   主程式開頭會將 `duration` 格式的 `samplingrate` 轉為數值（小時），並傳入 `Test7` 作為 `expected_interval`。然而 `Test7` 內部有 `dt <= (expected_interval * 1.5)`，其中 `dt` 為 `duration` 型別而 `expected_interval` 為 `double`，執行時可能會產生 `duration` 與 `double` 無法比較的錯誤；建議改為 `dt <= hours(expected_interval * 1.5)`。
3. **`Test10` 的視窗參數意義**：
   `Test10` 內部使用 `n_tst = round(test_duration / sampling_rate)` 換算點數，因此 `QC_settings.t10_n_tst` 代表的是**時間長度（小時）**，而非資料筆數。
4. **資料長度過短時之表現**：
   在 `Test10` 若 `length(input_item) < n_tst` 會直接回傳 `1`（或 `9`），未進行實質檢核；在 `Test6` 若資料少於 3 筆則全部回傳 `2`（或 `9`）。

---
*Author: DTY*
