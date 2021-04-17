function Installation()
    fprintf("Importing all Matlab files \n")
    folderlist = dir(fullfile(pwd, '**\*.*'));  %get list of files and folders in any subfolder
    folderlist = folderlist([folderlist.isdir]);  %remove folders from list

    for i = 1:length(folderlist)
       addpath(folderlist(i).folder)
    end
end