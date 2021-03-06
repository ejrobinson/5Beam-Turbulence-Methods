% Maricarmen Guerra Paris

% Open .mat files created with OceanContour Software from Nortek Signature 5 beam
% Transforms to ENU and XYZ velocities
% Save new files containing beam, ENU and XYZ velocities.
% % Save as: '/SS04_Sig_May2015_ENU_00000_' int2str(fnumber) '.mat'];
% Repeat for all MIDAS files
% Plots raw data

% May 30 2018 Note:
% Check if you have the new format
% ENU transformation might not work, because some variables from Data and
% Config structures are not available anymore

% Juluy 2019
% Info missing on Config is related to beam angles:
%     Config.BeamCfg1_theta=25;
%     Config.BeamCfg2_theta=25;
%     Config.BeamCfg3_theta=25;
%     Config.BeamCfg4_theta=25;
%
%
%     Config.BeamCfg1_phi=0;
%     Config.BeamCfg2_phi=-90;
%     Config.BeamCfg3_phi=180;
%     Config.BeamCfg4_phi=90;
%
%     Config.BeamCfg5_theta=0;
%     Config.BeamCfg5_phi=0;

% If you use Deployment software to create .mat files, ENU velocities might
% already be available, thus there is no need to convert them.

% Alternatively, you can create your own Beam to ENU script, using the
% rotation matrix information on .mat files.

% Note this ENU transformation does not include magnetic declination
% Hence, ENU velocities are with respect to magnetic north

% Feb 2021 [ejrobinson] 
% Changed to support data from OceanContour instead of MIDAS
% Changed to Windows slash convention (\)
% Changed to read all burst files in a folder


clear all, close all, clc

% Raw data files:

fileregexp = '^Burst.+(.mat)'


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

clear i ii iii tmp_d tmp_c tmp_ofn tmp_fn hold
%% Convert to ENU coordinates

[ Data2, Config2, T_beam2xyz ] = signatureAD2CP_beam2xyz_enu(Data,Config,'burst',1)
fnumber = 1;
% Save data with ENU coordinates
savefile=[savepath '\' prefix int2str(fnumber) '.mat'];
save(savefile, '-mat','Data2','Config2');


% % ENU Data
% figure(2), clf
% 
% 
%     
%     ax(1) = subplot(3,1,1); 
%     
%     pcolor(Data2.MatlabTimeStamp-datenum(2014,0,0), double(Data2.Range), double(Data2.VelX)' ), 
%     shading flat, 
%     datetick
%     set(gca,'YDir','reverse')
%     ylabel(['Vel X'])
%     caxis([-1 1])
%     colorbar,
%       ax(2) = subplot(3,1,2); 
%     
%     pcolor(Data2.MatlabTimeStamp-datenum(2014,0,0), double(Data2.Range), double(Data2.VelY)' ), 
%     shading flat, 
%     datetick
%     set(gca,'YDir','reverse')
%     ylabel(['Vel Y'])
%     caxis([-1 1])
%     colorbar,
% 
% ax(3) = subplot(3,1,3);
% pcolor(Data2.MatlabTimeStamp-datenum(2014,0,0), double(Data2.Range), double(Data2.VelZ1)' ), 
%     shading flat, 
%     datetick
%     set(gca,'YDir','reverse')
%     ylabel(['Vel Z'])
%     caxis([-1 1])
%     colorbar,
% 
% linkaxes(ax,'x')
% 
% % Battery life
% figure(3)
% plot(Data.MatlabTimeStamp-datenum(2014,0,0),Data.Battery)
% 

