function [anomalyScores, anomalyIndices] = isolationForest(feature, numTrees, subSampleSize)
    [N, ~] = size(feature);
    trees = cell(numTrees, 1);
    fprintf('开始构建 %d 棵孤立树...\n', numTrees);
    tic;
    for i = 1:numTrees
        idx = randperm(N, min(subSampleSize, N));
        X_sample = feature(idx, :);
        trees{i} = buildIsolationTree(X_sample, 0, ceil(log2(subSampleSize)));

        % 每10棵树输出一次进度
        if mod(i, 10) == 0 || i == numTrees
            fprintf('构建进度：%d / %d 棵树已完成\n', i, numTrees);
        end
    end
    toc;

    fprintf('开始计算每个样本的平均路径长度...\n');
    tic;
    pathLengths = zeros(N, 1);

    % 使用并行计算计算路径长度
    parfor i = 1:N
        x = feature(i, :);
        pathSum = 0;
        for t = 1:numTrees
            pathSum = pathSum + pathLength(x, trees{t}, 0);
        end
        pathLengths(i) = pathSum / numTrees;

        % 每处理1万个样本输出一次
        if mod(i, 10000) == 0 || i == N
            fprintf('路径长度计算进度：%d / %d\n', i, N);
        end
    end
    toc;

    % 异常评分
    c = 2 * (log(subSampleSize - 1) + 0.5772156649) - (2 * (subSampleSize - 1) / subSampleSize);
    anomalyScores = 2.^(-pathLengths / c);

    % 阈值可自定义，比如使用前1%的评分作为异常
    threshold = quantile(anomalyScores, 0.99);
    anomalyIndices = find(anomalyScores > threshold);

    fprintf('检测完成，共发现 %d 个异常值。\n', length(anomalyIndices));
end


% ----------------- 构建Isolation Tree -----------------
function tree = buildIsolationTree(X, currentDepth, maxDepth)
    [n, d] = size(X);
    if currentDepth >= maxDepth || n <= 1
        tree.size = n;
        tree.left = [];
        tree.right = [];
        tree.splitAtt = [];
        tree.splitValue = [];
        return;
    end

    splitAtt = randi(d);
    minVal = min(X(:, splitAtt));
    maxVal = max(X(:, splitAtt));
    if minVal == maxVal
        tree.size = n;
        tree.left = [];
        tree.right = [];
        tree.splitAtt = [];
        tree.splitValue = [];
        return;
    end

    splitValue = minVal + rand * (maxVal - minVal);
    leftIdx = X(:, splitAtt) < splitValue;
    rightIdx = ~leftIdx;

    tree.splitAtt = splitAtt;
    tree.splitValue = splitValue;
    tree.left = buildIsolationTree(X(leftIdx, :), currentDepth + 1, maxDepth);
    tree.right = buildIsolationTree(X(rightIdx, :), currentDepth + 1, maxDepth);
    tree.size = n;
end

% ----------------- 计算路径长度 -----------------
function length = pathLength(x, tree, currentLength)
    if isempty(tree.left) && isempty(tree.right)
        if tree.size <= 1
            length = currentLength;
        else
            length = currentLength + 2 * (log(tree.size - 1) + 0.5772156649) - (2 * (tree.size - 1) / tree.size);
        end
        return;
    end

    if x(tree.splitAtt) < tree.splitValue
        length = pathLength(x, tree.left, currentLength + 1);
    else
        length = pathLength(x, tree.right, currentLength + 1);
    end
end
