experiment_setup;



sizes = [100, 200, 500, 1000, 2000, 5000, 10000, 20000];

sizesToRun = sizes(6);

noOfSections = 8;
currentSection = 8;

for graphSize = sizesToRun
    
    roadDataFilename = ['./my_code/data/ROADS' ...
        num2str(graphSize)];
    load(roadDataFilename)
    % we now have ROADS and lroads loaded
    nGraphs = size(ROADS, 2);
    
    
    % Use these two rows for the first section:
    %fwCombinedROADS = cell(1, nGraphs);
    %fwCombinedRuntimesROADS = zeros(1, nGraphs);
    
    fwFilename = ['./my_code/data/fw_ROADS' ...
        num2str(graphSize)];
    fwRuntimeFilename = ...
        ['./my_code/data/fwRuntime_ROADS' ...
        num2str(graphSize)];
    % Use these rows for the other sections:
    load(fwFilename);
    load(fwRuntimeFilename);
    
    
    for section = currentSection
        fwSectionFilename = ['./my_code/data/fw_ROADS' ...
            num2str(graphSize) '-' num2str(section)];
        fwSectionRuntimeFilename = ...
            ['./my_code/data/fwRuntime_ROADS' ...
            num2str(graphSize) '-' num2str(section)];
        
        load(fwSectionFilename)
        load(fwSectionRuntimeFilename)
        % now we have fwROADS and fwRuntimesROADS
        
        
        startInd = floor((section-1)*(nGraphs/noOfSections))+1;
        stopInd = floor(section*(nGraphs/noOfSections));
        for i=startInd:stopInd
            fwCombinedROADS{i} = fwROADS{i};
            fwCombinedRuntimesROADS(i) = fwRuntimesROADS(i);
        end
        
        clear('fwRuntimesROADS');
        clear('fwROADS');
        

        save(fwFilename, 'fwCombinedROADS', '-v7.3');
        save(fwRuntimeFilename, 'fwCombinedRuntimesROADS', '-v7.3');
        
    end
 
    
end
disp('Done');
