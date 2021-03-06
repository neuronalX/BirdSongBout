% lowest of the low. We will apply the same tags as Liz the annotator did
% for all time points and disregard syllable edges and silences
% This code follows the file creation script 'NameAndMoveFiles'
%%
fs = 48000;
basedir = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/';
birds = {'bird_1' 'bird_2' 'bird_3' 'bird_4' 'bird_5' 'bird_6'};

for birdnum = 1:numel(birds)
    cd([basedir birds{birdnum}])
    load wavs_list;
    load tags;
    all_labels = [];
    % create a list of tags
    
    for fnum = 1:numel(syl_str)
        all_labels = [all_labels syl_str{fnum}*1];
    end
    all_labels = unique(all_labels);
    [all_labels,label_idx] = sort(all_labels); 
    
    cd mat;
    for fnum = 330:numel(wavs)
        
        load([wavs{fnum}(1:end-3) 'mat']);
        labels = zeros(1,numel(t));
        bnd = phrase_boundaries{fnum};
        for ct = 1:size(bnd,2)
            tm = bnd(1,ct);
            onset = max(1,floor(tm/48000/(t(2)-t(1))));
            tm = bnd(2,ct);
            offset = min(numel(t),ceil(tm/48000/(t(2)-t(1))));
            labels(onset:offset) = label_idx(all_labels==syl_str{fnum}(ct)*1);
        end
        save([wavs{fnum}(1:end-3) 'mat'],'s','t','f','labels');
        display(wavs{fnum});
        display([birdnum fnum/numel(syl_str)])
    end
end

%%
fs = 48000;
basedir = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/';
birds = {'bird_1' 'bird_2' 'bird_3' 'bird_4' 'bird_5' 'bird_6'};
syl_types_per_bird = zeros(1,6);
syl_per_file_per_bird = cell(1,6);
for birdnum = 1:numel(birds)
    cd([basedir birds{birdnum}])
    load wavs_list;
    load tags;
     all_labels = [];
    % create a list of tags
    
    for fnum = 1:numel(syl_str)
        all_labels = [all_labels syl_str{fnum}*1];
    end
    all_labels = unique(all_labels);
    [all_labels,label_idx] = sort(all_labels); 
    display([birdnum numel(all_labels)]);
    syl_types_per_bird(birdnum) = numel(all_labels);
    
    cd mat;
    syl_per_file = zeros(numel(wavs),numel(all_labels)+1);
    for fnum = 1:numel(wavs)
        load([wavs{fnum}(1:end-3) 'mat'],'labels');
        syl_per_file(fnum,unique(labels)+1) = 1;
    end
    syl_per_file_per_bird{birdnum} = syl_per_file;
end

%% Now prepare 5 comprehensive random training sets
for birdnum = 1:numel(birds)
    cd([basedir birds{birdnum}])
    load wavs_list;
    numtags = size(syl_per_file_per_bird{birdnum},2);
    
    for outnum = 1:5
        keys = {};
        for n_tag = 1:numtags
            idxs = find(syl_per_file_per_bird{birdnum}(:,n_tag)==1);
            n_idxs = numel(idxs);
            
            curr_idx = idxs(randi(n_idxs,min(n_idxs,1)));
            for cnt = 1:numel(curr_idx)
                keys = {keys{:} wavs{curr_idx(cnt)}};
             end
         end
        
        filename = [birds{birdnum} '_file_list' num2str(outnum) '.mat'];
        save(fullfile(basedir,birds{birdnum},'mat',filename),'keys');
    end
end
