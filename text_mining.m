%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Text Mining
%
%                                                  Written by Kim, Wiback,
%                                                     2016.06.08. Ver.1.1.
%                                                     2016.06.09. Ver.1.2.
%                                                     2016.06.10. Ver.1.3.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function text_mining





%% Main figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%
% Upper most figure
%%%%%%%%%%%%%%%%%%%
screen_size = get(0, 'screensize');
fg_size = [950, 700];
S.fg = figure('units', 'pixels', ...
    'position', ...
    [(screen_size(3) - fg_size(1)) / 2, ... % 1/2*(Screen's x - figure's x)
    (screen_size(4) - fg_size(2)) / 2, ... % 1/2*(Screen's y - figure's y)
    fg_size(1), ... % The figure's x
    fg_size(2)], ... % The figure's y
    'menubar', 'none', ...
    'name','Text Mining', ...
    'numbertitle', 'off', ...
    'resize', 'off');



%%%%%%
% Axes
%%%%%%

%%% Word cloud whiteboard
S.ax_word_cloud = axes('units', 'pixels', ...
    'position', [340, 10, 600, 620], ...
    'NextPlot', 'replacechildren', ...
    'xtick', {}, ...
    'ytick', {});
title(S.ax_word_cloud, 'Word Cloud', 'fontsize', 15)
box(S.ax_word_cloud, 'on')

%%% n-grams' table
S.n_gram_table = uitable(S.fg, 'units', 'pixels', ...
    'position', [10, 10, 320, 620]);
S.st_n_gram_title = uicontrol('style', 'text', ...
    'units', 'pixels', ...
    'position', [10, 633, 320, 20], ...
    'string', 'n-grams', ...
    'fontsize', 15, ...
    'fontweight', 'bold');



%%%%%%%%%%%%%
% Process bar
%%%%%%%%%%%%%
S.et_process = uicontrol('style', 'edit', ...
    'units', 'pix', ...
    'position', [345, 660, 260, 30], ...
    'string', 'Process bar', ...
    'fontsize', 20, ...
    'ForegroundColor', 'red', ...
    'backgroundcolor', [1, 1, 1], ...
    'horizontalalign', 'center', ...
    'visible', 'off', ...
    'fontweight', 'bold');



%%%%%%%%%%%%%%%
% Action button
%%%%%%%%%%%%%%%
S.pb_action = uicontrol('style', 'pushbutton', ...
    'units', 'pix', ...
    'position', [345, 660, 260, 30], ...
    'string', 'Load 1 or 2 Text(s)', ...
    'fontsize', 20, ...
    'ForegroundColor', 'red', ...
    'backgroundcolor', [0.7, 0.7, 0.7], ...
    'horizontalalign', 'center', ...
    'visible', 'on', ...
    'fontweight', 'bold');





%% Updating S %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All events are ephemeral (one shoot events), thus we only update once.
% That is, we do not have to retrieve any information after the analysis.
set(S.pb_action, 'callback', {@pb_action_callback, S})





%% Action Button Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pb_action_callback(~, ~, varargin)
        S = varargin{1};
        
        
        
        
        
        %% Action Button, Loading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(get(S.pb_action, 'string'), 'Load 1 or 2 Text(s)')
            
            
            
            %%%%%%%%%%%%%%%%%
            % Action: loading
            %%%%%%%%%%%%%%%%%
            
            %%% Loading
            [name, path] = uigetfile('*.txt', ...
                'Choose 1(2) Text(s)', ...
                'multiselect', 'on');
            
            %%% When 2 texts
            if iscell(name)
                fid_1 = fopen([path, name{1}], 'r');
                fid_2 = fopen([path, name{2}], 'r');
                S.txt_1 = textscan(fid_1, '%s');
                S.txt_2 = textscan(fid_2, '%s');
                fclose(fid_1);
                fclose(fid_2);
                
                %%% When 1 text
            else
                fid = fopen([path, name], 'r');
                S.txt_1 = textscan(fid, '%s');
                fclose(fid);
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Action: data to lowercase
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% Printing process + GUI transition
            set(S.pb_action, ...
                'visible', 'off', ...
                'enable', 'off')
            set(S.et_process, ...
                'visible', 'on', ...
                'string', 'Lowering Case')
            pause(0.5)
            
            %%%  When 2 texts
            if isfield(S, 'txt_2')
                S.txt_1 = lower(S.txt_1{1});
                S.txt_2 = lower(S.txt_2{1});
                
                %%%  When 1 text
            else
                S.txt_1 = lower(S.txt_1{1});
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Action: n-gram preparation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% Function cutting:
            % Usage  : cut_text = cutting(text, 'name', 'value')
            % 'name' : 'semantic'
            % 'value': 'true' or 'false' (default)
            % When true, all grammatical (functional) morphemes will be
            % cut.
            
            %%% When 2 texts
            if isfield(S, 'txt_2')
                % Printing process
                set(S.et_process, 'string', sprintf('Pruning %s', name{1}))
                drawnow
                % Do pruning.
                S.txt_1_uni = cutting(S.txt_1, 'semantic', 'true');
                S.txt_1_pre_bi = cutting(S.txt_1, 'semantic', 'false');
                % Printing process
                set(S.et_process, 'string', sprintf('Pruning %s', name{2}))
                drawnow
                % Do pruning.
                S.txt_2_uni = cutting(S.txt_2, 'semantic', 'true');
                S.txt_2_pre_bi = cutting(S.txt_2, 'semantic', 'false');
                
                %%% When 1 text
            else
                % Printing process
                set(S.et_process, 'string', sprintf('Pruning %s', name))
                drawnow
                % Do pruning.
                S.txt_1_uni = cutting(S.txt_1, 'semantic', 'true');
                S.txt_1_pre_bi = cutting(S.txt_1, 'semantic', 'false');
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Action: n-gram analysis with 2 texts
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isfield(S, 'txt_2')
                
                %%% S.txt_1_uni
                % Printing process
                set(S.et_process, ...
                    'string', sprintf('Uni_%s: 1/1', name{1}))
                pause(0.5)
                set(S.et_process, 'string', 'Counting & Sorting...')
                pause(0.5)
                % Counting
                S.txt_1_uni = tabulate(S.txt_1_uni);
                % Sorting
                [~, orig_index] = ...
                    sort(cell2mat(S.txt_1_uni(:, 2)), 'descend');
                % Uni-gram model
                S.txt_1_uni = S.txt_1_uni(orig_index, :);
                
                %%% S.txt_2_uni
                % Printing process
                set(S.et_process, ...
                    'string', sprintf('Uni_%s: 1/1', name{2}))
                pause(0.5)
                set(S.et_process, 'string', 'Counting & Sorting...')
                pause(0.5)
                % Counting
                S.txt_2_uni = tabulate(S.txt_2_uni);
                % Sorting
                [~, orig_index] = ...
                    sort(cell2mat(S.txt_2_uni(:, 2)), 'descend');
                % Uni-gram model
                S.txt_2_uni = S.txt_2_uni(orig_index, :);
                
                %%% S.txt_1_bi
                % Random index for random extraction
                % (we will not be using full corpus, it's too expensive.)
                random_i = randperm(length(S.txt_1_pre_bi), 3000);
                % Dummy bi-gram model to be stacked
                S.txt_1_bi = cell(...
                    length(random_i)*(length(random_i)-1), 1);
                % Counter
                pair = 1;
                % Randomly select first index.
                for random_select_1 = 1:length(random_i)
                    % Randomly select second index.
                    for random_select_2 = 1:length(random_i)
                        % Proceed only with different words.
                        if (random_select_1 ~= random_select_2) && ...
                                ~strcmp(...
                                S.txt_1_pre_bi{...
                                random_i(random_select_1)}, ...
                                S.txt_1_pre_bi{...
                                random_i(random_select_2)})
                            S.txt_1_bi{pair} = ...
                                [S.txt_1_pre_bi{random_i(random_select_1)}, ...
                                ' ', ...
                                S.txt_1_pre_bi{random_i(random_select_2)}];
                            pair = pair + 1;
                        end
                    end
                    % Printing process
                    set(S.et_process, ...
                        'string', ...
                        sprintf(...
                        'Bi_%s: %d/%d', ...
                        name{1}, random_select_1, length(random_i)))
                    drawnow
                end
                set(S.et_process, 'string', 'Counting & Sorting...')
                drawnow
                % Counting
                S.txt_1_bi(cellfun(@isempty, S.txt_1_bi)) = [];
                S.txt_1_bi = tabulate(S.txt_1_bi);
                % Sorting
                [~, orig_index] = ...
                    sort(cell2mat(S.txt_1_bi(:, 2)), 'descend');
                % Bi-gram model (with random 3000 words)
                S.txt_1_bi = S.txt_1_bi(orig_index, :);
                
                %%% S.txt_2_bi
                % Random index for random extraction
                % (we will not be using full corpus, it's too expensive.)
                random_i = randi(length(S.txt_2_pre_bi), [3000, 1]);
                % Dummy bi-gram model to be stacked
                S.txt_2_bi = cell(...
                    length(random_i)*(length(random_i)-1), 1);
                % Counter
                pair = 1;
                % Randomly select first index.
                for random_select_1 = 1:length(random_i)
                    % Randomly select second index.
                    for random_select_2 = 1:length(random_i)
                        % Proceed only with different words.
                        if (random_select_1 ~= random_select_2) && ...
                                ~strcmp(...
                                S.txt_2_pre_bi{...
                                random_i(random_select_1)}, ...
                                S.txt_2_pre_bi{...
                                random_i(random_select_2)})
                            S.txt_2_bi{pair} = ...
                                [S.txt_2_pre_bi{random_i(random_select_1)}, ...
                                ' ', ...
                                S.txt_2_pre_bi{random_i(random_select_2)}];
                            pair = pair + 1;
                        end
                    end
                    % Printing process
                    set(S.et_process, ...
                        'string', ...
                        sprintf(...
                        'Bi_%s: %d/%d', ...
                        name{2}, random_select_1, length(random_i)))
                    drawnow
                end
                set(S.et_process, 'string', 'Counting & Sorting...')
                drawnow
                % Counting
                S.txt_2_bi(cellfun(@isempty, S.txt_2_bi)) = [];
                S.txt_2_bi = tabulate(S.txt_2_bi);
                % Sorting
                [~, orig_index] = ...
                    sort(cell2mat(S.txt_2_bi(:, 2)), 'descend');
                % Bi-gram model (with random 3000 words)
                S.txt_2_bi = S.txt_2_bi(orig_index, :);
                
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Action: n-gram analysis with 1 text
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                
                %%% S.txt_1_uni
                % Printing process
                set(S.et_process, ...
                    'string', sprintf('Uni_%s: 1/1', name))
                pause(0.5)
                set(S.et_process, 'string', 'Counting & Sorting...')
                pause(0.5)
                % Counting
                S.txt_1_uni = tabulate(S.txt_1_uni);
                % Sorting
                [~, orig_index] = ...
                    sort(cell2mat(S.txt_1_uni(:, 2)), 'descend');
                % Uni-gram model
                S.txt_1_uni = S.txt_1_uni(orig_index, :);
                
                %%% S.txt_1_bi
                % Random index for random extraction
                % (we will not be using full corpus, it's too expensive.)
                random_i = randperm(length(S.txt_1_pre_bi), 3000);
                % Dummy bi-gram model to be stacked
                S.txt_1_bi = cell(...
                    length(random_i)*(length(random_i)-1), 1);
                % Counter
                pair = 1;
                % Randomly select first index.
                for random_select_1 = 1:length(random_i)
                    % Randomly select second index.
                    for random_select_2 = 1:length(random_i)
                        % Proceed only with different words.
                        if (random_select_1 ~= random_select_2) && ...
                                ~strcmp(...
                                S.txt_1_pre_bi{...
                                random_i(random_select_1)}, ...
                                S.txt_1_pre_bi{...
                                random_i(random_select_2)})
                            S.txt_1_bi{pair} = ...
                                [S.txt_1_pre_bi{random_i(random_select_1)}, ...
                                ' ', ...
                                S.txt_1_pre_bi{random_i(random_select_2)}];
                            pair = pair + 1;
                        end
                    end
                    % Printing process
                    set(S.et_process, ...
                        'string', ...
                        sprintf(...
                        'Bi_%s: %d/%d', ...
                        name, random_select_1, length(random_i)))
                    drawnow
                end
                set(S.et_process, 'string', 'Counting & Sorting...')
                drawnow
                % Counting
                S.txt_1_bi(cellfun(@isempty, S.txt_1_bi)) = [];
                S.txt_1_bi = tabulate(S.txt_1_bi);
                % Sorting
                [~, orig_index] = ...
                    sort(cell2mat(S.txt_1_bi(:, 2)), 'descend');
                % Bi-gram model (with random 3000 words)
                S.txt_1_bi = S.txt_1_bi(orig_index, :);
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Action: n-gram display
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% Printing process
            set(S.et_process, 'string', 'Displaying...')
            drawnow
            
            %%% Organizing before the display
            % When 2 texts
            if isfield(S, 'txt_2')
                [S.txt_1_uni{:, 4}] = deal('Uni');
                [S.txt_1_uni{:, 5}] = deal(name{1});
                [S.txt_1_bi{:, 4}] = deal('Bi');
                [S.txt_1_bi{:, 5}] = deal(name{1});
                [S.txt_2_uni{:, 4}] = deal('Uni');
                [S.txt_2_uni{:, 5}] = deal(name{2});
                [S.txt_2_bi{:, 4}] = deal('Bi');
                [S.txt_2_bi{:, 5}] = deal(name{2});
                % When 1 text
            else
                [S.txt_1_uni{:, 4}] = deal('Uni');
                [S.txt_1_uni{:, 5}] = deal(name);
                [S.txt_1_bi{:, 4}] = deal('Bi');
                [S.txt_1_bi{:, 5}] = deal(name);
            end
            
            %%% Actual display
            % When 2 texts
            if isfield(S, 'txt_2')
                set(S.n_gram_table, ...
                    'columnname', ...
                    {'Word', 'Freq', 'Percent', 'N-gram', 'Text'}, ...
                    'columnwidth', ...
                    {320/6+1, 320/6+1, 320/6+1, 320/6+1, 320/6+1}, ...
                    'rowname', ... % Top 20
                    {1:20, 1:20, 1:20, 1:20}, ...
                    'data', ... % Top 20
                    [S.txt_1_uni(1:20, :); S.txt_2_uni(1:20, :); ...
                    S.txt_1_bi(1:20, :); S.txt_2_bi(1:20, :)])
                % When 1 text
            else
                set(S.n_gram_table, ...
                    'columnname', ...
                    {'Word', 'Freq', 'Percent', 'N-gram', 'Text'}, ...
                    'columnwidth', ...
                    {320/6+1, 320/6+1, 320/6+1, 320/6+1, 320/6+1}, ...
                    'rowname', ... % Top 20
                    {1:20, 1:20}, ...
                    'data', ... % Top 20
                    [S.txt_1_uni(1:20, :); S.txt_1_bi(1:20, :)])
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Action: clouding analysis
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% Printing process
            set(S.et_process, 'string', 'Clouding...')
            drawnow
            
            %%% Path control
            txt_dir_path = strsplit(path, '/');
            txt_dir_path(end-1) = [];
            upper_most_directory = strjoin(txt_dir_path, '/');
            r_script_path = [upper_most_directory, 'wordcloud.r'];
            text_dir_path = [upper_most_directory, 'text_r/'];
            output_img_dir_path = [upper_most_directory, 'result_r/'];
            
            %%% Copying text(s) to the input directory of R
            mkdir(text_dir_path)
            %  When 2 texts
            if isfield(S, 'txt_2')
                copyfile([path, name{1}], [text_dir_path, name{1}])
                copyfile([path, name{2}], [text_dir_path, name{2}])
                %  When 1 text
            else
                copyfile([path, name], [text_dir_path, name])
            end
            
            %%% Calling R for the clouding analysis
            r_caller(r_script_path, text_dir_path);
            
            %%% Extracting result image(s)
            list = dir(output_img_dir_path);
            files = {list.name};
            % Killing everything, other than the result image(s)
            files(cellfun(@isempty, regexp(files, '.png$'))) = [];
            % when we have 2 images, proceed.
            if length(files) == 2
                img_1 = imread([output_img_dir_path, files{1}]);
                img_2 = imread([output_img_dir_path, files{2}]);
                % Merging the two, so we can display in one shoot.
                img = [img_1, img_2];
                % when we have 1 image, proceed.
            else
                img = imread([output_img_dir_path, files{1}]);
            end
            
            %%% Display
            imagesc(flipud(img), 'parent', S.ax_word_cloud)
            axis(S.ax_word_cloud, 'tight');
            % Change the title so that the user can see a wholistic flow.
            if length(files) == 2 % When 2 images
                title(S.ax_word_cloud, ['Common', ...
                    '                            ', ...
                    'vs', ...
                    '                            ', ...
                    'Comparing'], ...
                    'fontsize', 15);
            else % When 1 image
                title(S.ax_word_cloud, sprintf('Word Cloud: %s', ...
                    regexprep(name, '_', '\\_')))
            end
            
            %%% Eraze all by-products.
            rmdir(output_img_dir_path, 's')
            rmdir(text_dir_path, 's')
            delete([r_script_path, '.Rout'])
            
            %%% Printing process + GUI transition
            set(S.et_process, 'string', 'Done!')
            pause(0.5)
            set(S.pb_action, ...
                'visible', 'on', ...
                'enable', 'on', ...
                'string', 'Reset')
            set(S.et_process, ...
                'visible', 'off')
            drawnow
            
            
            
            
            
            %% Action Button, Resetting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(get(S.pb_action, 'string'), 'Reset')
            
            
            
            %%%%%%%%%%%%%%%
            % Action: reset
            %%%%%%%%%%%%%%%
            
            %%% Clearing table
            set(S.n_gram_table, 'data', [])
            
            %%% Clearing image
            cla(S.ax_word_cloud)
            % Title should be reset too.
            title(S.ax_word_cloud, 'Word Cloud', 'fontsize', 15)
            
            %%% Resetting the button's string
            set(S.pb_action, 'string', 'Load 1 or 2 Text(s)')
            drawnow
        end
    end





%% Cutting Func %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cut_text = cutting(varargin)
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Inputs & Name-Value pair
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% Name-value pair default
        if nargin < 2
            txt = varargin{1};
            name = 'semantic';
            value = 'false';
            
            %%% User specified name-value pair
        else
            txt = varargin{1};
            name = varargin{2};
            value = varargin{3};
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%
        % Regular expressions
        %%%%%%%%%%%%%%%%%%%%%
        rep_alphabets = '[a-z]*';
        rep_functionals = {'for', 'and', 'nor', ... % Conjunctions
            'but', 'or', 'yet', 'so', ... % Conjunctions
            'in', 'of', 'to', 'on', 'from', ... % Prepositions
            'with', 'under', 'throughout', ... % Prepositions
            'for', 'atop', 'until', ... % Prepositions
            'a', 'the', 'an', ... % Articles
            's', ... % Inflectional & Plural & 3rd person & Abbreviations
            't', 'm', 've', 'd'}; % Abbreviations
        
        
        
        %%%%%%%%%%%%%%%%%
        % Word extraction
        %%%%%%%%%%%%%%%%%
        
        %%% Parameters
        % Dummy output to stack cut data
        cut_text = cell(length(txt), 1);
        % The stack counter
        word = 1;
        
        %%% Common process for all the values
        % Extract only words.
        [start_index, end_index] = regexp(txt, rep_alphabets);
        for row = 1:length(start_index)
            % 1. When there are no alphabets found, jump the loop.
            % 2. When there is only 1 alphabetical sequences, extract that.
            % 3. When there are more than 2 seperated
            %    alphabetical sequences, extract them one by one.
            for in_row = 1:length(start_index{row})
                % Verbose
                cut_text{word} = ... % Cell{contents}
                    txt{row}(... % Cell{contents}
                    start_index{row}(in_row):... % Cell{contents}(shell)
                    end_index{row}(in_row)); % Cell{contents}(shell)
                % The stack counter
                word = word + 1;
            end
        end
        
        %%% Respective process for the value true.
        if strcmp(name, 'semantic') && strcmp(value, 'true')
            % Kill all the functionals.
            for each_cut = 1:length(rep_functionals)
                cut_text(...
                    ~cellfun(...
                    @isempty, regexp(...
                    cut_text, rep_functionals{each_cut}, 'once'))) = [];
            end
            
            %%% Respective process for the value false.
        else
            % Do nothing and pass.
        end
    end
end