function [flags] = Test8(input_item, rep_cnt_suspect, rep_cnt_fail, esp_val)
% ======================= FLAT LINE TEST ===========================
% ============================================= WRITE BY DTY =======
% 
%       CHECK WHETHER THE SENSOR IS STUCK AT A CONSTANT VALUE.
%       BASED ON QARTOD TEST 8.
% 
% ==================================================================
% ---- INPUT -------------------------------------------------------
% 
% INPUT_ITEM:               DATA
% 
% REP_CNT_FAIL:             THRESHOLD FOR SUSPECT (e.g., 3)
% 
% REP_CNT_SUSPECT:          THRESHOLD FOR FAIL (e.g., 5)
% 
% ESP:                      TOLERANCE FOR NUMERICAL ROUND-OFF ERROR
% 
% ---- OUTPUT ------------------------------------------------------
% 
% FLAGS:                    THE "PASS" AND "FAIL" DATA
%                               1: PASS
%                               3: SUSPECT(OUT OF USER_RANGE)
%                               4: FAIL(OUT OF SENSOR RANGE)
%                               9: MISSING
% 
% ==================================================================

arguments
    input_item
    rep_cnt_suspect double = 3
    rep_cnt_fail double = 5
    esp_val double = 0.5
end

input_item = input_item(:);

if rep_cnt_suspect >= rep_cnt_fail
    error('Test8 Error: rep_cnt_suspect needs to be less than rep_cnt_fail.');
end

flags = ones(size(input_item));
n = length(input_item);
% if n >= rep_cnt_suspect
%     % 計算 Suspect 範圍
%     % movmax(x, [k-1 0]) 代表包含當前點在內往回看 k 個點
%     range_suspect = movmax(input_item, [rep_cnt_suspect-1, 0], 'omitnan') - ...
%                     movmin(input_item, [rep_cnt_suspect-1, 0], 'omitnan');
% 
%     % 標記 Suspect (從第 k 個點開始才有意義)
%     idx_s = (range_suspect <= esp_val);
%     idx_s(1:rep_cnt_suspect-1) = false; % 前面不足點數的不算
%     flags(idx_s) = 3;
% end
% 
% if n >= rep_cnt_fail
%     % 計算 Fail 範圍
%     range_fail = movmax(input_item, [rep_cnt_fail-1, 0], 'omitnan') - ...
%                  movmin(input_item, [rep_cnt_fail-1, 0], 'omitnan');
% 
%     % 標記 Fail
%     idx_f = (range_fail <= esp_val);
%     idx_f(1:rep_cnt_fail-1) = false;
%     flags(idx_f) = 4;
% end


flags(isnan(input_item)) = 9;


for ii = 1:length(input_item)

    if flags(ii) == 9; continue; end

    if ii >= rep_cnt_fail
        window = input_item(ii - rep_cnt_fail +1 : ii);

        if any(isnan(window))
        else

            if all(abs(window - input_item(ii)) <= esp_val)
                flags(ii) = 4;
                continue
            end
        end
    end

    if ii >= rep_cnt_suspect
        window = input_item(ii - rep_cnt_suspect +1 : ii);

        if ~any(isnan(window))
            if all(abs(window - input_item(ii)) <= esp_val)
                flags(ii) = 3;
            end
        end
    end
end




end









