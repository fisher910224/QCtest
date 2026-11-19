function [orig_time, with_nan_data, with_nan_time] = find_missing_data(ipt_time, ipt, sr, tol)
if isnumeric(ipt_time)
    ipt_time = datetime(ipt_time, "ConvertFrom", "datenum");
end
if nargin < 3 || isempty(sr)
    sr = mode(diff(ipt_time));
elseif isnumeric(sr)
    sr = hours(sr); % 若傳入純數字（如 1 或 0.1667），強制轉為 hours duration
end
if nargin < 4 || isempty(tol)
    tol = min(sr * 0.1, minutes(2));
elseif isnumeric(tol)
    tol = hours(tol);
end
if nargin < 2
    ipt = zeros(size(ipt_time));
end

ipt_time = ipt_time(:);
ipt = ipt(:);

% 3. 建立以第一筆實際時間（含原本分秒，如 10:08:00）為基準的理想等間隔網格
orig_time = (ipt_time(1) : sr : ipt_time(end))';

% 4. 預設全為 NaN
with_nan_data = NaN(size(orig_time));
with_nan_time = NaT(size(orig_time));

% 5. 核心吸附運算：計算每筆觀測值對應到網格的哪一個索引 (k)
%    因為是等間隔網格，利用四捨五入 (round) 即可直接容許微小秒級飄移
time_steps = (ipt_time - orig_time(1)) ./ sr;
target_idx = round(time_steps) + 1;

% 6. 容許誤差檢查：確保資料漂移在 tol 範圍內，且索引在網格範圍內
valid_range = (target_idx >= 1) & (target_idx <= length(orig_time));
time_drift  = abs(ipt_time(valid_range) - orig_time(target_idx(valid_range)));
is_matched  = time_drift <= tol;

% 7. 正確填入資料（未匹配到的網格自動維持 NaN）
valid_idx = target_idx(valid_range);
valid_idx = valid_idx(is_matched);

valid_ipt = ipt(valid_range);
valid_ipt_time = ipt_time(valid_range);
valid_ipt = valid_ipt(is_matched);
valid_ipt_time = valid_ipt_time(is_matched);

with_nan_data(valid_idx) = valid_ipt;
with_nan_time(valid_idx) = valid_ipt_time;


% grid_time = (ipt_time(1) : sr : ipt_time(end))';
% TT_grid = timetable(grid_time);
% TT_data = timetable(ipt_time, ipt);
% TT_synced = synchronize(TT_grid, TT_data, 'nearest', 'Tolerance', tol);
% 
% orig_time = TT_synced.grid_time;
% with_nan_data = TT_synced.ipt;

% TT = timetable(ipt_time, ipt);
% TT_regular = retime(TT, 'regular', 'fillwithmissing', 'TimeStep', sr);
% orig_time = TT_regular.ipt_time;
% with_nan_data = TT_regular.ipt;

% orig_time = datetime(ipt_time(1)):sr:datetime(ipt_time(end));
% orig_time = orig_time(:);
% ipt_time = ipt_time(:);
% with_nan_data = NaN(size(orig_time));
% 
% ig = ismember(orig_time, ipt_time);
% if ~isempty(ipt)
%     with_nan_data(ig) = ipt;
% end

end