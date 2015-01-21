experiment_setup;

dataset = 'PROTO';
datasetName = 'PROTO';

paramsFilename = ...
    ['./my_code/data/params_', dataset];
load(paramsFilename);



%sizes = [100, 200, 500, 1000, 2000, 5000, 10000, 20000];
%nSizes = length(sizes);


runtimesFilename = ['./my_code/data/runtimes_', dataset];
load(runtimesFilename)
% loads stdPrepRuntimes, stdQueryRuntimes, smpFstPrepRuntimes, 
% smpFstQueryRuntimes, smpLstPrepRuntimes, smpLstQueryRuntimes

errAccFilename = ['./my_code/data/errAcc_', dataset];
load(errAccFilename);
% loads stdAccuracy, cat([smpLst smpFst vor] [Errors Accuracies])



%%

toPlotInds = 1:6;

stdPrepRuntimes = stdPrepRuntimes(:, toPlotInds);
stdQueryRuntimes = stdQueryRuntimes(:, toPlotInds);

smpFstPrepRuntimes = smpFstPrepRuntimes(:, toPlotInds);
smpFstQueryRuntimes = smpFstQueryRuntimes(:, toPlotInds);

smpFstPrepOps= smpFstPrepOps(:, toPlotInds);
smpFstQueryOps= smpFstQueryOps(:, toPlotInds);

smpLstPrepRuntimes = smpLstPrepRuntimes(:, toPlotInds);
smpLstQueryRuntimes = smpLstQueryRuntimes(:, toPlotInds);

vorPrepRuntimes = vorPrepRuntimes(:, toPlotInds, :);
vorQueryRuntimes = vorQueryRuntimes(:, toPlotInds, :);

vorPrepOps = vorPrepOps(:, toPlotInds, :);
vorQueryOps = vorQueryOps(:, toPlotInds, :);

stdAccuracy = stdAccuracy(:, toPlotInds);

smpLstErrors = smpLstErrors(:, toPlotInds);
smpLstDistErrors = smpLstDistErrors(:, toPlotInds);

smpFstErrors = smpFstErrors(:, toPlotInds);
smpFstDistErrors = smpFstDistErrors(:, toPlotInds);

vorErrors = vorErrors(:, toPlotInds, :);
vorDistErrors = vorDistErrors(:, toPlotInds, :);

smpLstAccuracies = smpLstAccuracies(:, toPlotInds);
smpFstAccuracies = smpFstAccuracies(:, toPlotInds);
vorAccuracies = vorAccuracies(:, toPlotInds, :);

sizesToPlot = sizes(toPlotInds);

stdTotalRuntimes = stdPrepRuntimes+stdQueryRuntimes;

smpFstTotalRuntimes = smpFstPrepRuntimes+smpFstQueryRuntimes;
smpFstTotalOps = smpFstPrepOps+smpFstQueryOps;

smpLstTotalRuntimes = smpLstPrepRuntimes+smpLstQueryRuntimes;

vorTotalRuntimes = vorPrepRuntimes+vorQueryRuntimes;
vorTotalOps = vorPrepOps+vorQueryOps;


%% Show results
% 

figure(1)
loglog(sizesToPlot, stdQueryRuntimes, '--o', ...
    sizesToPlot, smpLstQueryRuntimes(1, :), '--x', ...
    sizesToPlot, smpLstQueryRuntimes(end, :), '--*', ...
    sizesToPlot, smpFstQueryRuntimes(1, :), '--s', ...
    sizesToPlot, smpFstQueryRuntimes(end, :), '--d', ...
    sizesToPlot, vorPrepRuntimes(end, :, 1), '--^', ...
    sizesToPlot, vorPrepRuntimes(end, :, 2), '--v')
legend('Standard', ['SampleLast (m=', num2str(ms(1)), ')'], ...
    ['SampleLast (m=', num2str(ms(end)), ')'], ...
    ['SampleFirst (m=', num2str(ms(1)), ')'], ...
    ['SampleFirst (m=', num2str(ms(end)), ')'], ...
    ['Voronoi (m=', num2str(ms(end)), ', p=', ...
    num2str(densityFactors(1)), '\times n^{-2/3})'], ...
    ['Voronoi (m=', num2str(ms(end)), ', p=', ...
    num2str(densityFactors(2)), 'n^{-2/3})'], ...
    'Location', 'NorthEastOutside')
title(['Kernel computation query runtime on ', datasetName, ...
    ', n in [', num2str(sizesToPlot(1)), ', ', ...
    num2str(sizesToPlot(end)), ']'])
xlabel('Graph size')
ylabel('Mean query runtime (over 20 trials)')

%%

figure(2)
loglog(sizesToPlot, stdTotalRuntimes, '--o', ...
    ...%sizesToPlot, smpLstTotalRuntimes(1, :), '--x', ...
    sizesToPlot, smpLstTotalRuntimes(end, :), '--*', ...
    ...%sizesToPlot, smpFstTotalRuntimes(1, :), '--s', ...
    sizesToPlot, smpFstTotalRuntimes(end, :), '--d', ...
    sizesToPlot, vorTotalRuntimes(end, :, 1), '--^', ...
    sizesToPlot, vorTotalRuntimes(end, :, 2), '--v')
legend('Standard', ...
    ...%['SampleLast (m=', num2str(ms(1)), ')'], ...
    ['SampleLast (m=', num2str(ms(end)), ')'], ...
    ...%['SampleFirst (m=', num2str(ms(1)), ')'], ...
    ['SampleFirst (m=', num2str(ms(end)), ')'], ...
    ['Voronoi (m=', num2str(ms(end)), ', p=', ...
    num2str(densityFactors(1)), '\times n^{-2/3})'], ...
    ['Voronoi (m=', num2str(ms(end)), ', p=', ...
    num2str(densityFactors(2)), 'n^{-2/3})'], ...
    'Location', 'NorthEastOutside')
    %'Standard', 'Standard w/ preprocessing', ...
title(['Total kernel computation runtime on ', datasetName, ', n in [', ...
    num2str(sizesToPlot(1)), ', ', num2str(sizesToPlot(end)), ']'])
xlabel('Graph size')
ylabel('Mean runtime (over 20 trials)')

%%

graphSizeInd = 4;
graphSize = sizes(graphSizeInd);

figure(3)
semilogy([0 ms(end)+100], [1 1]*(stdQueryRuntimes(graphSizeInd)), ...
    [0 ms(end)+100], [1 1]*(stdTotalRuntimes(graphSizeInd)), 'k', ...
    ms, smpLstQueryRuntimes(:, graphSizeInd), '--o', ...
    ms, smpLstTotalRuntimes(:, graphSizeInd), '--o', ...
    ms, smpFstTotalRuntimes(:, graphSizeInd), '--o', ...
    ms, vorTotalRuntimes(:, graphSizeInd, 1), '--o', ...
    ms, vorTotalRuntimes(:, graphSizeInd, end), '--o')
xlim([0 ms(end)*1.1])
legend('Standard, query', 'Standard, total', ...
    'SampleLast, query', 'SampleLast, total', ...
    'SampleFirst, total', ...
    ['Voronoi, total (p=', num2str(densityFactors(1)) ,')'], ...
    ['Voronoi, total (p=', num2str(densityFactors(end)) ,')'], ...    
    'Location', 'NorthEastOutside')
title(['Kernel computation runtime on ', datasetName, ', n=', ...
    num2str(graphSize)])
xlabel('No. of samples')
ylabel('Mean runtime (per query or in total)')

%% Error, by graph size:

figure(4)
%plot(sizesToPlot, sizesToPlot*0, '-x', ...
%    sizesToPlot, smpLstErrors(1, :), '-x', ...
plot(sizesToPlot, smpLstErrors(1, :), '-x', ...
    sizesToPlot, smpLstErrors(end, :), '-x', ...
    sizesToPlot, smpFstErrors(1, :), '-x', ...
    sizesToPlot, smpFstErrors(end, :), '-x', ...
    sizesToPlot, vorErrors(end, :, 1), '-x', ...
    sizesToPlot, vorErrors(end, :, 2), '-x')

%xlim([0 ms(end)*1.1])

%legend('Standard', ...
%    ['SampleLast, m=', num2str(ms(1))], ...
legend(['SampleLast, m=', num2str(ms(1))], ...
    ['SampleLast, m=', num2str(ms(end))], ...
    ['SampleFirst, m=', num2str(ms(1))], ...
    ['SampleFirst, m=', num2str(ms(end))], ...
    ['Voronoi, m=', num2str(ms(end)), ', p=', num2str(densityFactors(1))], ...
    ['Voronoi, m=', num2str(ms(end)), ', p=', num2str(densityFactors(2))], ...
    'Location', 'NorthEastOutside')

title(['Kernel value errors on ', datasetName, ', n in [', ...
    num2str(sizesToPlot(1)), ', ', ...
    num2str(sizesToPlot(end)), ']'])
xlabel('Graph size')
ylabel('Mean kernel value error (over 20 trials)')

%% Error, by sample size:

graphSizeInd = 3;
graphSize = sizes(graphSizeInd);

figure(5)
plot([0 ms(end)+100], [0 0], ...
    ms, smpLstErrors(:, graphSizeInd), '--o', ...
    ms, smpFstErrors(:, graphSizeInd), '--x', ...
    ms, vorErrors(:, graphSizeInd, 1), '--o', ...
    ms, vorErrors(:, graphSizeInd, end), '--o')
xlim([0 ms(end)*1.1])
legend('Standard', ...
    'SampleLast', 'SampleFirst', ...
    ['Voronoi, p=', num2str(densityFactors(1))], ...
    ['Voronoi, p=', num2str(densityFactors(end))], ...
    'Location', 'NorthEastOutside')
title(['Kernel value errors on ', datasetName, ', n=', ...
    num2str(graphSize)])
xlabel('Sample size')
ylabel('Mean kernel value error (over 20 trials)')

%% Distribution error, by sample size:

graphSizeInd = 3;
graphSize = sizes(graphSizeInd);

figure(6)
plot([0 ms(end)+100], [0 0], ...
    ms, smpLstDistErrors(:, graphSizeInd), '--o', ...
    ms, smpFstDistErrors(:, graphSizeInd), '--o', ...
    ms, vorDistErrors(:, graphSizeInd, 1), '--o', ...
    ms, vorDistErrors(:, graphSizeInd, end), '--o')
xlim([0 ms(end)*1.1])
legend('Standard', ...
    'SampleLast', 'SampleFirst', ...
    ['Voronoi, p=', num2str(densityFactors(1))], ...
    ['Voronoi, p=', num2str(densityFactors(end))], ...
    'Location', 'NorthEastOutside')
title(['Shortest path distribution errors on ', datasetName, ', n=', ...
    num2str(graphSize)])
xlabel('Sample size')
ylabel('Mean sp-distribution error (over 20 trials)')

%% Accuracy, by graph size:

m1 = 1;
m2 = nMValues;

figure(7)
plot(sizesToPlot, stdAccuracy, '-x', ...
    sizesToPlot, smpLstAccuracies(m1, :), '-x', ...
    sizesToPlot, smpLstAccuracies(m2, :), '-x', ...
    sizesToPlot, smpFstAccuracies(m1, :), '-x', ...
    sizesToPlot, smpFstAccuracies(m2, :), '-x', ...
    sizesToPlot, vorAccuracies(m2, :, 1), '-x', ...
    sizesToPlot, vorAccuracies(m2, :, 2), '-x', ...
    sizesToPlot, vorAccuracies(m2, :, 3), '-x')
%xlim([0 ms(end)*1.1])

legend('Standard', ...
    ['SampleLast, m=', num2str(ms(m1))], ...
    ['SampleLast, m=', num2str(ms(m2))], ...
    ['SampleFirst, m=', num2str(ms(m1))], ...
    ['SampleFirst, m=', num2str(ms(m2))], ...
    ['Voronoi, m=', num2str(ms(m2)), ', p=', num2str(densityFactors(1))], ...
    ['Voronoi, m=', num2str(ms(m2)), ', p=', num2str(densityFactors(2))], ...
    ['Voronoi, m=', num2str(ms(m2)), ', p=', num2str(densityFactors(3))], ...
    'Location', 'NorthEastOutside')

title(['Kernel accuracies on ', datasetName, ', n in [', ...
    num2str(sizesToPlot(1)), ', ', ...
    num2str(sizesToPlot(end)), ']'])
xlabel('Graph size')
ylabel('Mean kernel accuracy in % (over 20 trials)')

%% Accuracy, by sample size:

graphSizeInd = 4;
graphSize = sizes(graphSizeInd);

figure(8)
plot([0 ms(end)+100], stdAccuracy(graphSizeInd)*[1 1], ...
    ms, smpLstAccuracies(:, graphSizeInd), '--o', ...
    ms, smpFstAccuracies(:, graphSizeInd), '--o', ...
    ms, vorAccuracies(:, graphSizeInd, 1), '--o', ...
    ms, vorAccuracies(:, graphSizeInd, 2), '--o')
xlim([0 ms(end)*1.1])
legend('Standard', ...
    'SampleLast', 'SampleFirst', ...
    ['Voronoi, p=', num2str(densityFactors(1))], ...
    ['Voronoi, p=', num2str(densityFactors(2))], ...
    'Location', 'NorthEastOutside')
title(['Kernel accuracies on ', datasetName, ', n=', ...
    num2str(graphSize)])
xlabel('Sample size')
ylabel('Mean kernel accuracy in % (over 20 trials)')


%%

flog = @(x)x.*log(x);
a = 10000;
b = 5*10^6;

figure(9)
loglog(sizesToPlot, smpFstTotalOps(1, :), '--o', ...
         sizesToPlot, smpFstTotalOps(end, :), '--s', ...
         sizesToPlot, vorTotalOps(end, :, 1), '--d', ...
         sizesToPlot, vorTotalOps(end, :, 2), '--^');%, ...
%         sizesToPlot, b+a*flog(sizesToPlot), '-.')
legend(['SampleFirst, (m=', num2str(ms(1)), ')'], ...
       ['SampleFirst, (m=', num2str(ms(end)), ')'], ...
       ['Voronoi, (m=', num2str(ms(end)), '), p=', ...
       num2str(densityFactors(1)), ')'], ...
       ['Voronoi, (m=', num2str(ms(end)), '), p=', ...
       num2str(densityFactors(2)), ')'], ...
       'Location', 'NorthWest')
    %'Standard', 'Standard w/ preprocessing', ...
title(['Dijkstra operations counts for ', datasetName, ', n in [', ...
    num2str(sizesToPlot(1)), ', ', num2str(sizesToPlot(end)), ']'])
xlabel('Graph size')
ylabel('Mean operations count (over 20 trials)')

