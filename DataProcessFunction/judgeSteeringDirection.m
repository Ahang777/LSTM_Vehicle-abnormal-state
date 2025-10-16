function result = judgeSteeringDirection(angle_series)
% 输入: angle_series 是方向盘角度的时序数据（列向量）
% 输出: result 是数字，右转为1，左转为-1

if size(angle_series,2) ~= 1
    error('输入必须是列向量');
end

n = length(angle_series);

% 计算每个时间点的角度变化（即差分）
delta_angle = diff(angle_series);  % 一阶差分

% 判断转向方向
if mean(delta_angle) > 0
    result = 1;     % 右转：整体角度逐渐增大
else
    result = -1;    % 左转：整体角度逐渐减小
end

end
