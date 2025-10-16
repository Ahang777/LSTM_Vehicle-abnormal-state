window_size = 30;
data = FilteredData(:, 10);  % 第8列为目标列
num_samples = length(data);

% 初始化特征矩阵：6列（范数、变化值、均值、方差、最大值、最小值）
feature = zeros(num_samples - window_size + 1, 6);

fprintf('开始提取特征，总共 %d 个滑动窗口...\n', size(feature,1));

for i = 1:(num_samples - window_size + 1)
    window = data(i:i + window_size - 1);

    norm_val = norm(window);  % 默认是2范数
    mean_val = mean(window);
    std_val = std(window);
    max_val = max(window);
    min_val = min(window);

    if i == 1
        delta_norm = 0;
    else
        prev_window = data(i-1:i + window_size - 2);
        delta_norm = norm_val - norm(prev_window);
    end

    feature(i, :) = [norm_val, delta_norm, mean_val, std_val, max_val, min_val];

    if mod(i, 100000) == 0
        fprintf('已处理 %d 个窗口...\n', i);
    end
end

fprintf('特征提取完成，共生成 %d 组特征。\n', size(feature,1));