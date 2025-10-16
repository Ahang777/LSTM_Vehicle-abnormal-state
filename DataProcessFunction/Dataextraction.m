%读取CSV文件数据
filename = 'Data.csv';

fid = fopen(filename, 'r');
if fid == -1
    error('无法打开文件: %s', filename);
end

% 跳过第一行（表头）
fgetl(fid);

% 初始化
chunk_size = 5000000;  % 初始分配500万行
data_all = zeros(chunk_size, 45);  % 每行45个数
unique_vals = [];
row_idx = 1;
total_rows = chunk_size;

disp('开始读取数据...');

while true
    line = fgetl(fid);

    if line == -1
        break;  % 到达文件末尾
    end

    this_row = str2double(strsplit(line, ','));

    if length(this_row) ~= 45 || any(isnan(this_row))
        continue;  % 数据无效，跳过
    end

    if row_idx > total_rows
        data_all(total_rows+1000000, 45) = 0;  % 每次加100万行空间
        total_rows = total_rows + 1000000;
    end

    data_all(row_idx, :) = this_row;

    % 更新第一列唯一值
    val = this_row(1);
    if ~ismember(val, unique_vals)
        unique_vals(end+1) = val;
    end

    % 每处理10万行输出一次
    if mod(row_idx, 100000) == 0
        fprintf('已读取 %d 行，第一列唯一值数量: %d\n', row_idx, length(unique_vals));
    end

    % 判断是否达到停止条件
    if length(unique_vals) >= 15
        fprintf('已达到15个唯一第一列值，停止读取。\n');
        break;
    end

    row_idx = row_idx + 1;
end

% 截取实际读取部分
data_all = data_all(1:row_idx-1, :);
fclose(fid);

fprintf('读取完成，共读取 %d 行数据。\n', row_idx-1);

writematrix(Rawdata, 'Rawdata.csv');

% 需要删除的列索引
cols_to_delete = [2, 4, 5, 6, 10, 11, 12, 13, 14, 17, 18, 19, 22, 23, 26, 27, 28, ...
                  29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45];

% 删除指定的列
RawData_cleaned = Rawdata(:, ~ismember(1:size(Rawdata, 2), cols_to_delete));

% 输出处理后的数据的列数
final_cols = size(RawData_cleaned, 2);
disp(['删除后的数据列数: ', num2str(final_cols)]);

% 更新 RawData 为最终处理后的数据
Rawdata = RawData_cleaned;