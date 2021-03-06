clear all; close all; clc;

load('ImageStatsHuman_val_50_filtered.mat');
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

load(['/home/mengmi/Projects/Proj_context2/mturk/ProcessMturk/Mat/mturk_expA_GTlabel_compiled.mat']);

subjidlist = {'subject04-ay','subject05-in','subject06-bg','subject08-ap','subject09-az'};
TotalTrialNum = 440;
NumType = 8;
NumBins = 4;

for s = 1:length(subjidlist)
    
    %load human responses and compare with ground truth collected
    fid = fopen(['results/response_' subjidlist{s} '.txt'],'r');
    counter = 1;
    responseList = {};
    tline = fgetl(fid);    
    while ischar(tline)
        %disp(tline);
        tline(isspace(tline)) = [];
        responseList{counter} = tline;
        counter=counter+1;
        tline = fgetl(fid);
    end
    fclose(fid);
    
    result = [];
    
    for t = 1:TotalTrialNum
        load(['audio/' subjidlist{s} '/trial_audio_' num2str(t) '.mat']);
        bin = myaudio.MM_selectedbin;
        cate = myaudio.MM_selectedcate;
        imgid = myaudio.MM_selectedobjid;
        type = myaudio.MM_selectedtype;
        
        indimg = find(classList == cate & objList == imgid & binList == bin);
        res = responseList{t};
        gt  = GTmturk{indimg}; 
        
        flag = 0;
        if length(res)<3
            correct = nan;
            flag = 1;
        end
        counter = 0;
        forbidden = {' don''t','no','none','idk','dontknow','bullshit','clueless','nothing','sth','unknown','--','?'};
        for f= 1:length(forbidden)
            if strcmp(forbidden{f},res)
                counter = 1;
                break;
            end
        end 
        if counter == 1
            correct = nan;
            flag = 1;
        end
        
        if flag == 0
            if fcn_spellcheck(res, gt)
                correct = 1;
            else
                correct = 0;
            end
        end
        
        result = [result correct];        
        
    end
    save(['results/result_' subjidlist{s} '_mturk_cmp.mat'],'result');
    size(result)
end