function plot_action_windows(data, idx1, idx2, idx3, num_samples)
% 优化后的动作片段绘图函数，支持三组动作索引绘图
% data: Nx1 数组
% idx1, idx2, idx3: 三组动作的起始索引
% num_samples: 每组随机绘制样本数量

    window_size = 30;
    N = length(data);

    % 越界过滤
    idx1 = idx1(idx1 + window_size - 1 <= N);
    idx2 = idx2(idx2 + window_size - 1 <= N);
    idx3 = idx3(idx3 + window_size - 1 <= N);

    % 随机抽样
    if length(idx1) > num_samples
        idx1 = datasample(idx1, num_samples, 'Replace', false);
    end
    if length(idx2) > num_samples
        idx2 = datasample(idx2, num_samples, 'Replace', false);
    end
    if length(idx3) > num_samples
        idx3 = datasample(idx3, num_samples, 'Replace', false);
    end

    figure; hold on;
    title('横滚角速度数据对比');
    xlabel('时间窗口K=30');
    ylabel('横滚角速度');

    % 绘制动作组1：蓝色圆点线
    for i = 1:length(idx1)
        segment = data(idx1(i):idx1(i) + window_size - 1);
        h1 = plot(0:window_size-1, segment, '-o', ...
            'Color', [0 0.447 0.741 0.5], ...
            'MarkerSize', 4, 'LineWidth', 1.2, ...
            'DisplayName', '向左急转向');
        if i > 1
            set(h1, 'HandleVisibility', 'off');
        end
    end

    % 绘制动作组2：红色方点线
    for i = 1:length(idx2)
        segment = data(idx2(i):idx2(i) + window_size - 1);
        h2 = plot(0:window_size-1, segment, '-s', ...
            'Color', [0.850 0.325 0.098 0.5], ...
            'MarkerSize', 4, 'LineWidth', 1.2, ...
            'DisplayName', '向右急转向');
        if i > 1
            set(h2, 'HandleVisibility', 'off');
        end
    end

    % 绘制动作组3：绿色菱形点线
    for i = 1:length(idx3)
        segment = data(idx3(i):idx3(i) + window_size - 1);
        h3 = plot(0:window_size-1, segment, '-d', ...
            'Color', [0.466 0.674 0.188 0.5], ...
            'MarkerSize', 4, 'LineWidth', 1.2, ...
            'DisplayName', '平缓行驶');
        if i > 1
            set(h3, 'HandleVisibility', 'off');
        end
    end

    legend('Location', 'best');
    grid on;
    box on;
end
