%提取出异常数据集
ab_Position = Position(sortedTop5Percent, :);

%添加索引序列
ab_Position(:,7) = sortedTop5Percent;

ab_Position(:,3) = -ab_Position(:,3);

%进行处理
for i = 1:339837
    ab_Position(i,8) = 0.2*ab_Position(i,1)+0.6*ab_Position(i,4) + 0.2*ab_Position(i,2);
end

% 根据第7列的数值升序排序
sortAcc = sortrows(ab_Position, 8);

%提取最后5000行数据
sortAcc = sortAcc((end-10000):end,:);

%按照第7列排序
sortAcc = sortrows(sortAcc, 7);

suoyin = sortAcc(1,1);
for i = 2:23685
    if((sortAcc(i,1)-suoyin)<30)
        sortAcc(i,:) = 0;
    else
        suoyin = sortAcc(i,1);
    end
end

% 找出每一行是否全为 0
rowsToKeep = any(sortAcc ~= 0, 2);  % 返回逻辑向量，非零行为 true

% 保留非全零的行，压缩矩阵
sortAcc = sortAcc(rowsToKeep, :);

result = [];
for i = 1:1123
    window_data = FilteredData(sortAcc(i,7):sortAcc(i,7)+29, 10);
    result(i,1) = judgeSteeringDirection(window_data);
    disp(result);
end

% 假设你给定了一个随机的窗口索引
window_index = 154970;  % 你可以随机给定一个索引

% 提取FilteredData第8列中从window_index开始的30个数据
window_size = 30;  % 窗口大小为30
window_data = FilteredData(window_index:window_index+window_size-1, 10);

% 设置横坐标为窗口索引（0到30）
x_values = window_index:window_index+window_size-1;

% 绘制该窗口的数据图
figure;
plot(x_values, window_data, 'b-', 'LineWidth', 2);
title(['第8列数据窗口：', num2str(window_index), '到', num2str(window_index + window_size - 1)]);
xlabel('数据索引');
ylabel('第8列数据');
grid on;