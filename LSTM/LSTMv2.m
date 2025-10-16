%% 清空环境变量
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行

%% 导入数据
load('Accdata.mat');    % 加载 Acc 训练数据
load('Breakdata.mat');  % 加载 Break 训练数据
load('Leftdata.mat');   % 加载 Left 训练数据
load('Rightdata.mat');  % 加载 Right 训练数据
load('Normaldata.mat'); % 加载 Normal 训练数据

% 假设每个数据集的大小为 15000x10，
% 包含500个片段，每个片段为30x10

%% 数据分割成片段（保持为 30x10 格式）
P = []; % 初始化特征数据
T = []; % 初始化标签数据

% 存放5个数据集：4个原有数据集 + 新添加的 Normaldata
data_sets = {Accdata, Breakdata, Leftdata, Rightdata, Normaldata};

for i = 1:length(data_sets)  % 对每个数据集进行处理，这里 length(data_sets) 为 5
    data = data_sets{i};  % 获取当前数据集
    [num_samples, num_features] = size(data);  % 15000 x 10

    % 每30行作为一个片段（500个片段）
    for j = 1:(num_samples / 30)
        start_row = (j-1)*30 + 1;
        end_row   = j*30;
        segment_data = data(start_row:end_row, :);  % 30x10
        P = cat(3, P, segment_data);  % 拼接到第三维度上，最终 P 尺寸为 30x10x(500*5)
    end
end

% 生成标签（假设：Accdata为1, Breakdata为2, Leftdata为3, Rightdata为4, Normaldata为5）
labels = [repmat(1, 500, 1); 
          repmat(2, 500, 1); 
          repmat(3, 500, 1); 
          repmat(4, 500, 1); 
          repmat(5, 500, 1)];
% labels 本身为列向量（2500x1）

% 转换为 categorical，保证输出为列向量
t_all = categorical(labels);  % 2500x1 categorical

%% 检查 P 的尺寸，应为 [30, 10, 2500]
disp(size(P));  % 期望输出 [30, 10, 2500]

%% 划分训练集和测试集
temp = randperm(length(labels));  % 随机打乱索引

% 选择训练样本（例如这里可以根据比例调整训练集数量，比如70%训练集）
numTotal = length(labels);
numTrain = round(0.7 * numTotal);  % 训练集样本数
numTest = numTotal - numTrain;      % 测试集样本数

P_train_numeric = P(:, :, temp(1:numTrain));
T_train = t_all(temp(1:numTrain));  % 保持为列向量

P_test_numeric = P(:, :, temp(numTrain+1:end));
T_test = t_all(temp(numTrain+1:end));  % 保持为列向量

%%【关键修改】转换数值数组为 cell 数组，每个 cell 存放一个序列
M = size(P_train_numeric, 3);  % 训练集样本数
N = size(P_test_numeric, 3);   % 测试集样本数

P_train = cell(1, M);
for i = 1:M
    % 转置，每个片段原尺寸为 30x10，转置为 10x30：这样每个序列有10个特征、30个时间步
    P_train{i} = P_train_numeric(:, :, i)';
end

P_test = cell(1, N);
for i = 1:N
    P_test{i} = P_test_numeric(:, :, i)';
end

%% 创建网络
layers = [ ...
    sequenceInputLayer(10)               % 输入层，期望每个时间步有10个特征
%     lstmLayer(3, 'OutputMode', 'last')     % LSTM层，3个单元，输出最后一个时间步
    lstmLayer(6, 'OutputMode', 'last')
    reluLayer                            % ReLU激活层
%     fullyConnectedLayer(5)               % 全连接层，输出类别数改为5
    fullyConnectedLayer(5)
    softmaxLayer                         % Softmax层
    classificationLayer];                % 分类层

%% 参数设置
options = trainingOptions('adam', ...
    'MaxEpochs', 1000, ...
    'InitialLearnRate', 0.01, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 750, ...
    'Shuffle', 'every-epoch', ...
    'ValidationPatience', Inf, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

%% 训练模型
[net,info] = trainNetwork(P_train, T_train, layers, options);

%% 仿真预测
t_sim1 = predict(net, P_train);
t_sim2 = predict(net, P_test);

%% 将预测结果转换为索引
T_sim1 = vec2ind(t_sim1');
T_sim2 = vec2ind(t_sim2');

%% 性能评价
error1 = sum(T_sim1 == double(T_train)) / M * 100;
error2 = sum(T_sim2 == double(T_test)) / N * 100;

%% 查看网络结构
analyzeNetwork(net)

%% 绘图（示例）
figure
plot(1:M, double(T_train), 'r-*', 1:M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
title({'训练集预测结果对比'; ['准确率 = ' num2str(error1) '%']})
grid

figure
plot(1:N, double(T_test), 'r-*', 1:N, T_sim2, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
title({'测试集预测结果对比'; ['准确率 = ' num2str(error2) '%']})
grid

%% 将预测结果转换为 categorical 类型，保证与真实标签类型一致
T_sim1_cat = categorical(T_sim1);
T_sim2_cat = categorical(T_sim2);

%% 绘制混淆矩阵
figure
cm = confusionchart(T_train, T_sim1_cat);
cm.Title = 'Confusion Matrix for Train Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';

figure
cm = confusionchart(T_test, T_sim2_cat);
cm.Title = 'Confusion Matrix for Test Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';

% 绘制准确率图像
figure;
plot(info.TrainingAccuracy, 'LineWidth', 1.5);
xlabel('Epoch');
ylabel('Accuracy (%)');
title('Training Accuracy');
grid on;
saveas(gcf, 'training_accuracy.png');  % 保存图像

% 绘制损失图像
figure;
plot(info.TrainingLoss, 'LineWidth', 1.5);
xlabel('Epoch');
ylabel('Loss');
title('Training Loss');
grid on;
saveas(gcf, 'training_loss.png');  % 保存图像
