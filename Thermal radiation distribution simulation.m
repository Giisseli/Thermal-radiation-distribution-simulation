%This function calculates radiative heatflux and its distribution from a
%flat heat source to a parallel flat simulation plane. It requires thermal
%distribution of heat source in .csv format aquired for example with a
%infrared camera. Higher resolution data causes longer simulation times. 
%For reference, 209*384 image and 31*58 simulation plane takes about 5 
%minutes to run on my somewhat powerful 2020 model desktop computer. Use 
%centimeters for dimensions and celcius for panel temperature data.

clear;

% simulation setup

Save = 0;                       %Set this to 1 to save heatflux distribution map 
FileName = 'heatfluxmap.csv';   %set file name for save results   

Panel = flip(readmatrix('1000Wpanel2.csv'),2); %read CSV file of thermal image of heater panel. Flip to make results better line up with real viewpoint
PanelSize = size(Panel);

PanelX = 31;            %Physical dimensions of heater panel. These should be the same as limits of thermal image used
PanelY = 59;

PanelE = 0.91; %panel emissivity

%for simulation plane positions 0,0 is in top left corner of panel positive
%X-direction being down and positive Y being right. Location coordinates
%indicate the location of top left corner of simulatin plane.

SimPlaneX = 31;    % Simulation plane X size
SimPlaneY = 59;    % Simulation plane Y size
SimPlaneLocX = 0;     % Simulation plane location X
SimPlaneLocY = 0;     % Simulation plane location Y

ResX = 1;   % Simulation plane simulation resolution X
ResY = 1;   % Simulation plane simulation resolution Y

SepDis = 15;     % separation distance between heat source and Simulation plane

SensorTemp = 240 + 273.15;   %sensor surface absolute temperature

StefBoltz = 5.670373*10^(-8); %Stefan-Boltzmann constant

%initializing values

PanelResX = PanelX/PanelSize(1); %Calculating dimensions of thermal image datapoints
PanelResY = PanelY/PanelSize(2);
PixelSize = PanelResX*PanelResY;

i = SimPlaneLocX/ResX;                      
j = SimPlaneLocY/ResY;
k = 1;
l = 1;
HFA = zeros(SimPlaneX/ResX,SimPlaneY/ResY);   %Setting up array for heatflux results
HF = 0;

%simulation

%loops to calculate heatflux from each datapoint of heater panel to each
%segment of Simulation plane.

while i*ResX < SimPlaneX+(SimPlaneLocX/ResX)
    while j*ResY < SimPlaneY+(SimPlaneLocY/ResY)
        while k < PanelSize(1)+1
            while l < PanelSize(2)+1
                Xa = [PanelResX*k,PanelResX*(k+1)];   %setting up panel segment
                Ya = [PanelResY*l,PanelResY*(l+1)];
            
                Xb = [i*ResX,i*ResX+ResX];        %setting up Simulation plane
                Yb = [j*ResY,j*ResY+ResY];
            
                HF = HF + (View_Factor(Xa,Ya,Xb,Yb,SepDis)*StefBoltz*PanelE*PixelSize*(((Panel(k,l)+273.15)^4)-((SensorTemp)^4))*10); %calculate heat flux from panel pixel to Simulation plane segment.  The 10 is to account for centimeters as units
                l = l+1;
            end                
            k = k+1;
            l = 1;
        end
        
        HFA(i+1-(SimPlaneLocX/ResX),j+1-(SimPlaneLocY/ResY)) = HF + HFA(i+1-(SimPlaneLocX/ResX),j+1-(SimPlaneLocY/ResY));       % Saving heatflux data to array
        HF = 0;
        k = 1;
        j = j+1;
    end
    j = SimPlaneLocY/ResY;
    i = i+1;
    Progress = i*100/SimPlaneX+(SimPlaneLocX/ResX);      
    fprintf('Simulation progress %.0f%%.\n', Progress);         %progress report to provide some insight on progress being made
end

%print results
figure;
HMHFA = heatmap(HFA,'Units','points','InnerPosition',[50,50,10*SimPlaneY,10*SimPlaneX],'Colormap', turbo);    %print heatmap of heatflux results
figure;
HMP = heatmap(flip(Panel,2),'Units','points','InnerPosition',[50,50,10*PanelY,10*PanelX],'Colormap', turbo);    %print heatmap of panel. Flip to align it with view from simulation plane
f = figure;
f.Position = [100 100 SimPlaneY*20 SimPlaneX*20];

contourf(flip(HFA,1));         %make contourgraph. Flip up to down to align with other figures.
if Save == 1
    writematrix(HFA,FileName); %save results as .csv for further use
end
