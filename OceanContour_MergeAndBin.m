%% OceanContour - Join exported burst files with existing ENU data and bin into sampling periods

fileregexp = '^(Burst_\d\d\d.VTC).+(\d.mat)'


fpath = 'G:\GA_OceanContour_TEST'; % Folder containing input burst files
fpath_c = replace(fpath,'\','\\');

flist = dir(fpath);
flist = extractfield(flist,'name');
flist = string(flist);
fmatch = regexp(flist,fileregexp);
fmatch = find(~cellfun('isempty',fmatch))

%fnumber=2; %Number of files

% Save Files info
prefix = ['Out_']; %where to save the files
savepath = ['G:\GA_OceanContour_TEST']; %Sequential name of files


%% Raw Data - load each file and append to a fake burst file before overwriting the original (will need to add extra variables if later functions use them)
for i = 1:length(fmatch)

  hold = load(sprintf('%s%s%s',[fpath_c,'\\',flist(fmatch(i))]));
  if i == 1
    tmp_d = hold.Burst_Data;
    tmp_c = hold.Config ;
    tmp_ofn = fieldnames(hold.Burst_Data);
    tmp_fn = replace(tmp_ofn,'%','');
    %tmp_ofn = replace(tmp_ofn,'%','''%');

 % This is a temporary fix for ocean contour having a few variables which contain special characters (%) 
  else
    for ii = 1:length(tmp_fn)
        if (ii<12) && (ii>8)
        else
            tmp_d.(tmp_fn{ii}) = [tmp_d.(tmp_fn{ii}) hold.Burst_Data.(tmp_fn{ii})];
        end
    end
  end

end
Data = tmp_d;
Config = tmp_c;
