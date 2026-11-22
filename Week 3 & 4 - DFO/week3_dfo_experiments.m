%{
DFO experiments for the wiki: tables + plots
Runs Dispersive Flies Optimisation (al-Rifaie, 2014) on Sphere and Rastrigin.
 Part 1: 30 runs per function (D=30)          -> main table
 Part 2: impact of dimensionality              -> table + plot
 Part 3: impact of disturbance threshold delta -> table + plot
 Part 4: convergence curves
Needs MATLAB R2016b+ (local functions in scripts). Put this single file anywhere and run it.
Outputs: results_*.csv, fig_*.png, and wiki-ready text printed to the command window.
%}
clear; clc; close all;
rng(42);                                % reproducible results
% ---------- SETTINGS ----------
N = 100; maxIter = 1000; nRuns = 30;
lowerB = -5.12; upperB = 5.12;
funcs      = {@sphere_f, @rastrigin_f};
funcNames  = {'Sphere', 'Rastrigin'};
D0 = 30; delta0 = 0.001;
dimList    = [2 10 30 50 100];
deltaList  = [0 0.001 0.01 0.05 0.1 0.3];
%% ---------- PART 1: MAIN TABLE (30 runs, D=30, delta=0.001) ----------
nF = numel(funcs);
final1 = zeros(nRuns, nF);
conv1  = zeros(nRuns, maxIter, nF);
for k = 1:nF
   for r = 1:nRuns
       [best, hist] = dfo(funcs{k}, N, D0, delta0, maxIter, lowerB, upperB);
       final1(r,k) = best; conv1(r,:,k) = hist;
   end
end
T1 = summaryTable(final1, funcNames);
disp('=== TABLE 1: 30 runs, D=30, delta=0.001 ==='); disp(T1);
writetable(T1, 'results_main.csv');
printWiki(T1, 'Table 1 (30 runs, D=30, delta=0.001)');
figure; boxplot(final1, 'Labels', funcNames); set(gca,'YScale','log');
ylabel('Final best fitness (log)'); title('DFO: 30 runs, D=30');
saveas(gcf, 'fig_boxplot.png');
%% ---------- PART 2: DIMENSIONALITY ----------
rows = []; names = {};
med2 = zeros(numel(dimList), nF);
for k = 1:nF
   for a = 1:numel(dimList)
       v = zeros(nRuns,1);
       for r = 1:nRuns
           v(r) = dfo(funcs{k}, N, dimList(a), delta0, maxIter, lowerB, upperB);
       end
       rows = [rows; stats(v)]; %#ok<AGROW>
       names{end+1,1} = sprintf('%s D=%d', funcNames{k}, dimList(a)); %#ok<SAGROW>
       med2(a,k) = median(v);
   end
end
T2 = array2table(rows, 'VariableNames', {'Median','Min','Max','Std'}, 'RowNames', names);
disp('=== TABLE 2: effect of dimensionality ==='); disp(T2);
writetable(T2, 'results_dimensionality.csv', 'WriteRowNames', true);
printWiki(T2, 'Table 2 (dimensionality, delta=0.001)');
figure;
for k = 1:nF
   subplot(1,nF,k); semilogy(dimList, med2(:,k), '-o', 'LineWidth', 1.5); grid on;
   xlabel('Dimensions D'); ylabel('Median final fitness'); title(funcNames{k});
end
saveas(gcf, 'fig_dimensionality.png');
%% ---------- PART 3: DISTURBANCE THRESHOLD ----------
rows = []; names = {};
med3 = zeros(numel(deltaList), nF);
for k = 1:nF
   for a = 1:numel(deltaList)
       v = zeros(nRuns,1);
       for r = 1:nRuns
           v(r) = dfo(funcs{k}, N, D0, deltaList(a), maxIter, lowerB, upperB);
       end
       rows = [rows; stats(v)]; %#ok<AGROW>
       names{end+1,1} = sprintf('%s delta=%g', funcNames{k}, deltaList(a)); %#ok<SAGROW>
       med3(a,k) = median(v);
   end
end
T3 = array2table(rows, 'VariableNames', {'Median','Min','Max','Std'}, 'RowNames', names);
disp('=== TABLE 3: effect of disturbance threshold (D=30) ==='); disp(T3);
writetable(T3, 'results_delta.csv', 'WriteRowNames', true);
printWiki(T3, 'Table 3 (disturbance threshold, D=30)');
figure;
for k = 1:nF
   subplot(1,nF,k); semilogy(1:numel(deltaList), med3(:,k), '-o', 'LineWidth', 1.5); grid on;
   set(gca, 'XTick', 1:numel(deltaList), 'XTickLabel', string(deltaList));
   xlabel('Disturbance threshold \delta'); ylabel('Median final fitness'); title(funcNames{k});
end
saveas(gcf, 'fig_delta.png');
%% ---------- PART 4: CONVERGENCE ----------
figure;
for k = 1:nF
   subplot(1,nF,k);
   semilogy(median(conv1(:,:,k),1), 'LineWidth', 1.5); grid on;
   xlabel('Iteration'); ylabel('Median best fitness (30 runs)'); title(funcNames{k});
end
saveas(gcf, 'fig_convergence.png');
disp('Done. CSVs and PNGs saved in the current folder.');
%% ====================== LOCAL FUNCTIONS ======================
function [bestFit, hist] = dfo(fobj, N, D, delta, maxIter, lowerB, upperB)
   % Same algorithm as DFO.m (elitism, ring topology, disturbance, bounds reset),
   % with the inner loop over dimensions vectorised for speed.
   X = lowerB + rand(N,D)*(upperB-lowerB);
   hist = zeros(1,maxIter);
   for itr = 1:maxIter
       fitness = fobj(X);
       [sFit, s] = min(fitness);
       hist(itr) = sFit;
       for i = 1:N
           if i == s, continue; end
           left = mod(i-2,N)+1; right = mod(i,N)+1;
           if fitness(right) < fitness(left), b = right; else, b = left; end
           newX = X(b,:) + rand(1,D).*(X(s,:) - X(i,:));       % update equation
           rnd  = lowerB + rand(1,D)*(upperB-lowerB);
           out  = newX < lowerB | newX > upperB;                % out of bounds control
           dist = rand(1,D) < delta;                            % disturbance
           newX(out) = rnd(out);
           newX(dist) = rnd(dist);
           X(i,:) = newX;
       end
   end
   bestFit = min(fobj(X));
end
function y = sphere_f(X)
   y = sum(X.^2, 2);
end
function y = rastrigin_f(X)
   D = size(X,2);
   y = 10*D + sum(X.^2 - 10*cos(2*pi*X), 2);
end
function s = stats(v)
   s = [median(v) min(v) max(v) std(v)];
end
function T = summaryTable(M, funcNames)
   S = zeros(numel(funcNames), 4);
   for k = 1:numel(funcNames), S(k,:) = stats(M(:,k)); end
   T = array2table(S, 'VariableNames', {'Median','Min','Max','Std'}, 'RowNames', funcNames(:));
end
function printWiki(T, caption)
   % Prints a markdown table you can paste into the wiki.
   fprintf('\n**%s**\n\n| Setting | Median | Min | Max | Std |\n|---|---|---|---|---|\n', caption);
   for i = 1:height(T)
       fprintf('| %s | %.3e | %.3e | %.3e | %.3e |\n', T.Properties.RowNames{i}, ...
           T.Median(i), T.Min(i), T.Max(i), T.Std(i));
   end
   fprintf('\n');
end
