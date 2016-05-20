% Author: Gizem Kucukoglu
% April 2015

function render_bumpy_fits(fit_results)

%% Render bumpy spheres using the fit results
% Gloss level: 0,10,20...,100 % gloss
% bump_level: 0.4 to 4.4 in increments of 0.4
% needs mat file of best fit parameter values as an 11x3 matrix
% rows: [1-matte, 2-10%, 3-20%, ..., 11- 100% gloss]
% cols: [rho_s rho_d alpha]

%scene14.hdr

load(fit_results)
lf = 4;
for bump = 1:11
    for gloss = 1:11
        for meshCount = 1:22
            
            row_no = gloss;
            var = renderParams(row_no,:);
            
            ro_s = ['300:',num2str(var(1)),' 800:',num2str(var(1))];
            mean_diffuse = mean(renderParams(:,2));
            ro_d = ['300:',num2str(mean_diffuse),' 800:',num2str(mean_diffuse)];
            alphau = var(3);
            
            mycell = {ro_s, ro_d, alphau};
            
            T = cell2table(mycell, 'VariableNames', {'ro_s' 'ro_d' 'alphau'});
            writetable(T,'/scratch/gk925/render_imgstats_5by5/outdoor/LO4/bumpy_fitrender_Conditions.txt','Delimiter','\t')
            
            % Set preferences
            setpref('RenderToolbox3', 'workingFolder', '/scratch/gk925/render_imgstats_5by5/outdoor/LO4');
            
            % use this scene and condition file.
            parentSceneFile = ['GBMeshD',num2str(bump),'G',num2str(gloss),'LO',num2str(lf),'C',num2str(meshCount),'.dae']
            conditionsFile = 'bumpy_fitrender_Conditions.txt';
            %     mappingsFile = ['bumpy',bump_level,'_5by5_correctCameraDistDefaultMappings.txt'];
            mappingsFile = 'MeshLF4DefaultMappings.txt'
            
            % Make sure all illuminants are added to the path.
            addpath(genpath(pwd))
            
            % which materials to use, [] means all
            hints.whichConditions = [];
            
            % Choose batch renderer options.
            hints.imageWidth = 550;
            hints.imageHeight = 550;
            datetime=datestr(now);
            datetime=strrep(datetime,':','_'); %Replace colon with underscore
            datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
            datetime=strrep(datetime,' ','_');%Replace space with underscore
            hints.recipeName = ['GBMeshD',num2str(bump),'G',num2str(gloss),'LO',num2str(lf),'C',num2str(meshCount),'-' datetime];
            
            ChangeToWorkingFolder(hints);
            
            %comment all this out
            toneMapFactor = 10;
            isScale = true;
            
            for renderer = {'Mitsuba'}
                
                % choose one renderer
                hints.renderer = renderer{1};
                
                % make 3 multi-spectral renderings, saved in .mat files
                nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
                radianceDataFiles = BatchRender(nativeSceneFiles, hints);
                
                % condense multi-spectral renderings into one sRGB montage
                montageName = sprintf('GBMeshD%sG%sLO%sC%s', num2str(bump), num2str(gloss), num2str(lf), num2str(meshCount));
                montageFile = [montageName '.png'];
                [SRGBMontage, XYZMontage] = ...
                    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
                
                % display the sRGB montage
                % ShowXYZAndSRGB([], SRGBMontage, montageName);
            end
            
            
        end
    end
end




