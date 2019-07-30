%make_illustrative_movie.m
%
%Compute 3D data first before running this code for your experiment
%This function plots 3D reconstruction data alongside 2D tracking performed from all cameras
%In addition this function makes a movie of the same
%
%Files required: Video files must be present in the experiment folder consisting 2D annotated videos 
%as illustrated in the experiment Rubikscube_DLC2d
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/recon3D


clear 
close all
clc

%Take initialized values from config file
config_DLC2d

load([exp_path '/' exp_name '/Data3d/Data3d.mat'],'coords3dall')

%Code to visualize 2d videos with 3d reconstruction results
figure('units','normalized','outerposition',[0 0 1 1])
colorclass = colormap(jet); %jet is default in DLC to-date
color_map_self=colorclass(1:nfeatures:64,:);

%Place your DLC labelled video files in the project under Videos folder

v = dir([exp_path '/' exp_name '/Videos/*.mp4']);
cam = cell(ncams,1);
for icams = 1:ncams
    cam{icams,1} = VideoReader([v(icams,1).folder '/' v(icams,1).name]);
end

%to make video
vidfile = VideoWriter([exp_path '/' exp_name '/Videos/Demo2D_3Dmovie.mp4'],'MPEG-4');
vidfile.FrameRate = fps;
open(vidfile)

if ~mod(size(cam,1),2)
    subplot_size = size(cam,1);
else
    subplot_size = size(cam,1)+1;
end
    
subplot_cols = ceil(subplot_size/2);

%setting maximum and minimum of axis of visualization
xvals = coords3dall(:,1:3:nfeatures*3); 
yvals = coords3dall(:,2:3:nfeatures*3);
zvals = coords3dall(:,3:3:nfeatures*3);

xmax = max(xvals(:));
xmin = min(xvals(:));
ymax = max(yvals(:));
ymin = min(yvals(:));
zmax = max(zvals(:));
zmin = min(zvals(:));



for i =1:1:size(coords3dall,1) 
    temp = reshape(coords3dall(i,:),3,nfeatures);
    subplot(2,subplot_cols,1)
    scatter3(temp(1,:),temp(2,:),temp(3,:),250*ones(1,nfeatures),color_map_self(1:nfeatures,:),'filled');
    hold on
    for l = 1:size(drawline,1)
        pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
        line(pts(:,1), pts(:,2), pts(:,3),'color','k','linewidth',1.5)
    end
    hold off
    %view to be set to suit the object being tracked 
    set(gca,'xtick',[],'ytick',[],'ztick',[],'view',[-10.0500   30.6124],'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax],'Zdir', 'reverse') %change view and axis limits to fit your data
    
    
    for n = 1:size(cam,1)
        subplot(2,subplot_cols,n+1)
        b = read(cam{n,1}, i);
        imshow(b)
        drawnow
    end
    set(gcf, 'color', 'white')
    frame = getframe(gcf);
    writeVideo(vidfile,frame);

end

close(vidfile)