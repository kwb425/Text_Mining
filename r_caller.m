%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple .r caller
% 
%%% Usage: 
% r_caller('your/r/script/absolute/path', ...
% 'directory/holding/texts')
%
%%% R requirments: 
% 1. Version. 3.2. (or 3.1., 3.3.) https://www.r-project.org
% 2. library(wordcloud)            install.packages("wordcloud")
% 3. library(png)                  install.packages("png")
% 4. library(tm)                   install.packages("tm")
% 5. library(RColorBrewer)         install.packages("RColorBrewer")
%
%                                                  Written by Kim, Wiback,
%                                                  2016. 06. 06. Ver. 1.1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r_caller(r_script_path, text_dir_path)





%% Pre-processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%
% Initial error handling
%%%%%%%%%%%%%%%%%%%%%%%%

%%% File should end without '/', directory should end with '/'.
if strcmp(r_script_path(end), '/')
    r_script_path(end) = [];
elseif ~strcmp(text_dir_path(end), '/')
    text_dir_path(end+1) = '/';
end

%%% When encountered with some kind of path error, handle it.
try 
list = dir(text_dir_path);
files = {list.name};
catch
disp('Check your path, and try again.') 
end

%%% When no txt files are present, toss error.
if sum(~cellfun(@isempty, regexp(files, '.txt$'))) == 0 
disp('Empty text folder. Check, and try again.')
end

%%% When R version is different, toss error 
% (different systems can have different R versions.).
r_souce_path = ...
    '/Library/Frameworks/R.framework/Versions/3.2/Resources/bin/R';
if ~exist(r_souce_path, 'file')
sprintf(['Check your R source path, sould be something like: \n', ...
'/Library/Frameworks/R.framework/Versions/...'])
end





%% Editing .r From MATLAB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%% 
% Reading
%%%%%%%%%

%%% Read R script.
fid = fopen(r_script_path, 'r');
txt = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
txt = txt{1};



%%%%%%%%%
% Editing
%%%%%%%%%

%%% Edit some portion (directory setting) of the script.
% The text folder should be direct child of the upperomost directory.
text_dir_path = strsplit(text_dir_path, '/'); 
% Going 1 up from the text folder
text_dir_path(end-1) = []; 
% The upper-most directory's absolute path
uppermost = strjoin(text_dir_path, '/'); 
% Replace R script's directory settings by the user's.
replaced = regexprep(txt, ...
'directory = .*', ... % Change this,
['directory = ', '"', uppermost, '"']); % to this.
% Re-write the R script with the replaced contents.
fid = fopen(r_script_path, 'w');
fprintf(fid, '%s\n', replaced{:});
fclose(fid);





%% Executing R From MATLAB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Word clouding...')



%%%%%%%%%%%%%%
% Calling bash
%%%%%%%%%%%%%%
% BATCH command: program_source CMD BATCH program_script
system(sprintf('%s CMD BATCH %s', r_souce_path, r_script_path));
%disp('Done!')
end