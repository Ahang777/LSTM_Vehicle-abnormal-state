% ======== 参数区域（你只需要改这几行） ========
columns_to_plot = [12];   % 👈 改成你想画的列号
sample_size = 300;              % 连续取样数量
% ==============================================

% 获取总行数
total_rows = size(Rawdata, 1);

% 随机选一个起点，确保不越界
start_idx = randi([1, total_rows - sample_size + 1]);

% 连续索引
sample_indices = start_idx:(start_idx + sample_size - 1);

% 提取时间列（第2列）和你指定的列
sample_time = Rawdata(sample_indices, 2);
sample_signals = Rawdata(sample_indices, columns_to_plot);

% 绘图
figure;
plot(sample_time, sample_signals, '.-');
xlabel('时间');
ylabel('数值');
title(sprintf('连续 %d 行（第 %d 至 %d 行）数据展示', ...
    sample_size, start_idx, start_idx + sample_size - 1));
legend(arrayfun(@(x) sprintf('第%d列', x), columns_to_plot, 'UniformOutput', false), ...
       'Location', 'bestoutside');
grid on;

% 设置 SG 滤波参数
window_size = 21;  % 必须为奇数
poly_order = 3;    % 多项式阶数

% 初始化一个副本矩阵保存滤波后的数据
FilteredData = Rawdata;

% 对第6、7、8列进行SG滤波处理
for col = [6, 7, 8]
    FilteredData(:, col) = sgolayfilt(Rawdata(:, col), poly_order, window_size);
end