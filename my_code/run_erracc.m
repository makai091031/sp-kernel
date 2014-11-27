%% Setup

experiment_setup;

dataset = 'GENP';

paramsFilename = ...
    ['./my_code/data/params_', dataset];
load(paramsFilename);

%sizes = [100, 200, 500, 1000, 2000, 5000, 10000, 20000];

%%

sizesToRun = sizes(1);

doStandard = 1;
doSampling = 1;
doVoronoi = 1;

for graphSize = sizesToRun
    %% Pick out the data
    
    dataFilename = ['./my_code/data/', dataset ...
        num2str(graphSize)];
    load(dataFilename)
    % we now have GRAPHS and lgraphs loaded
    smpFstFilename = ['./my_code/data/smpFstKrnVal_', dataset ...
        num2str(graphSize)];
    load(smpFstFilename)
    % we now have sampleFirstKernelValues and sampleFirstRunTimes loaded
    smpLstFilename = ['./my_code/data/smpLstKrnVal_', dataset ...
        num2str(graphSize)];
    load(smpLstFilename)
    % we now have sampleLastKernelValues and sampleLastRunTimes loaded
    stdKrnFilename = ['./my_code/data/stdKrnVal_', dataset ...
        num2str(graphSize)];
    load(stdKrnFilename)
    % we now have standardKernelValues and standardKernelRuntime loaded
    
    
    clear fwCombined;
    disp('Loading fw data')
    fwFilename = ['./my_code/data/fw_', dataset ...
        num2str(graphSize)];
    load(fwFilename)
    % we now have fw (or fwCombined) loaded
    if exist('fwCombined', 'var')
        disp('Using fwCombinedR instead of fwR')
        fw = fwCombined;
    end
    
    
    nDensities = length(densities);
    
    Graphs = GRAPHS;
    labels = lgraphs;
    shortestPathMatrices = fw;
    
    nMValues = length(ms);
    
    %% Accuracy reference number
    % run svm for non-sampling kernel, to get reference numbers
    
    
    if doStandard
        % i.e. partition needs to be in two labeled sets
        
        disp('Computing standard kernel accuracy:')
        
        K = cell(1,1);
        K{1} = standardKernelValues;
        
        stdTrialAcc = zeros(1,nTrials);
        for j = 1:nTrials
            [standardKernelSvmRes] = runsvm(K,labels);
            stdTrialAcc(j) = standardKernelSvmRes.mean_acc;
        end
        stdKrnAccuracy = mean(stdTrialAcc);
        
        refAccFilename = ...
            ['./my_code/data/stdAcc_', dataset ...
            num2str(graphSize)];
        save(refAccFilename, 'stdKrnAccuracy');
    end
    
    if doSampling
        
        %% Comparison across sample numbers
        % compare kernel values from different sample numbers,
        % different kernels, to the standard sp-kernel
        % also runtime and accuracy
        
        
        
        % Two separate sampled kernels -> two columns of values
        
        smpFstAvgError = zeros(nMValues, 1);
        smpLstAvgError = zeros(nMValues, 1);
        %smpFstAvgAccuracy = zeros(nMValues, 1);
        %smpLstAvgAccuracy = zeros(nMValues, 1);
        
        
        smpFstAvgRunTimes = mean(sampleFirstRunTimes, 2);
        smpLstavgRunTimes = mean(sampleLastRunTimes, 2);
        
        
        %% Errors:
        
        disp('Computing kernel value errors')
        
        for i = 1:nMValues
            sampleLastError = 0;
            sampleFirstError = 0;
            for j = 1:nTrials
                sampleLastK = sampleLastKernelValues{i,j};
                sampleLastError = sampleLastError + ...
                    sum(sum(abs(sampleLastK-standardKernelValues))) / ...
                    (nGraphs^2);
                
                sampleFirstK = sampleFirstKernelValues{i,j};
                sampleFirstError = sampleFirstError + ...
                    sum(sum(abs(sampleFirstK-standardKernelValues))) / ...
                    (nGraphs^2);
                
            end
            smpLstAvgError(i) = sampleLastError/nTrials;
            smpFstAvgError(i) = sampleFirstError/nTrials;
        end
        %
        
        % store the error values:
        errorsFilename = ...
            ['./my_code/data/errVal_', dataset ...
            num2str(graphSize)];
        save(errorsFilename, 'smpLstAvgError', 'smpFstAvgError');
        
        %% Accuracy:
        
        disp('Computing sampling kernel classification accuracies:')
        
        cellK = cell(1,1);
        
        sampleFirstAccuracy = zeros(nMValues, nTrials);
        sampleLastAccuracy = zeros(nMValues, nTrials);
        
        
        for i = 1:nMValues
            for j = 1:nTrials
                
                disp('Acc. for SampleLast kernel')
                sampleLastK = sampleLastKernelValues{i,j};
                cellK{1} = sampleLastK;
                [res] = runsvm(cellK, labels);
                sampleLastAccuracy(i,j) = res.mean_acc;
                
                disp('Acc. for SampleFirst kernel')
                sampleFirstK = sampleFirstKernelValues{i,j};
                cellK{1} = sampleFirstK;
                [res] = runsvm(cellK, labels);
                sampleFirstAccuracy(i,j) = res.mean_acc;
                
                
                disp(['Finished accuracies for trial ', num2str(j), ...
                    ', m-value ', num2str(i)]);
                
            end
            disp(['Finished accuracies for all trials, m-value ', ...
                num2str(i), ' out of ', num2str(nMValues)]);
        end
        smpLstAvgAccuracy = mean(sampleLastAccuracy, 2);
        smpFstAvgAccuracy = mean(sampleFirstAccuracy, 2);
        
        % store the accuracy values
        accFilename = ...
            ['./my_code/data/accVal_', dataset ...
            num2str(graphSize)];
        save(accFilename, 'smpLstAvgAccuracy', 'smpFstAvgAccuracy');
        
        
        
    end %of "if doSampling"
    
    if ~doSampling
        errorsFilename = ...
            ['./my_code/data/errVal_', dataset ...
            num2str(graphSize)];
        load(errorsFilename);
        accFilename = ...
            ['./my_code/data/accVal_', dataset ...
            num2str(graphSize)];
        load(accFilename);
    end
    
    
    %% Voronoi, error and accuracy
    if doVoronoi
        vorAccuracy = zeros(nMValues, nTrials);
        vorAvgAccuracy = zeros(nMValues, nDensities);
        vorAvgError = zeros(nMValues, nDensities);
        
        for d = 1:length(densities)
            density = densities(d);
            
            disp(['Voronoi kernel, density = ' num2str(density)])
            
            vorValuesFilename = ...
                ['./my_code/data/vorKrnVal_', dataset ...
                num2str(graphSize) '_' num2str(density) '.mat'];
            load(vorValuesFilename);
            
            vorError = 0;
            
            
            for i = 1:nMValues
                for j = 1:nTrials
                    
                    % Error value
                    vorK = voronoiKernelValues{i,j};
                    vorError = vorError + ...
                        sum(sum(abs(vorK-standardKernelValues))) / ...
                        (nGraphs^2);
                    
                    % Accuracy
                    vorK = voronoiKernelValues{i,j};
                    cellK{1} = vorK;
                    [res] = runsvm(cellK, labels);
                    vorAccuracy(i,j) = res.mean_acc;
                end
                disp(['Finished all trials, m = ' num2str(i)])
                vorAvgError(i, d) = vorError/nTrials;
            end
            vorAvgAccuracy(:,d) = mean(vorAccuracy, 2);
            
            save(accFilename, 'smpLstAvgAccuracy', 'smpFstAvgAccuracy', ...
                'vorAvgAccuracy');
            save(errorsFilename, 'smpLstAvgError', 'smpFstAvgError', ...
                'vorAvgError');
            
        end
        
        

        
    end
    
    
    
    
    
end

% Overview:


% accuracy: use all trials for sample-last, build mean accuracy per graph
% size, per sample size
% for now: ignore sample-first since it should be the same anyway
% UPDATE 2015-10-15: try using both and see if it can be done (i.e., will
% computations take less than, like, a week)

% error: use all trials for both sample-last and and sample-first




