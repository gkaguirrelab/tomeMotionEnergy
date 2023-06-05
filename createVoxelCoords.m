% tmp dir
tmp = '/home/ozzy/Desktop/temp';
if ~isfile(tmp)
    mkdir(tmp)
end

% Path to angle, eccentricity and sigma cifti maps
angle = '/home/ozzy/Downloads/TOME_3017_cifti_maps/TOME_3017_inferred_angle.dtseries.nii';
eccen = '/home/ozzy/Downloads/TOME_3017_cifti_maps/TOME_3017_inferred_eccen.dtseries.nii';
sigma = '/home/ozzy/Downloads/TOME_3017_cifti_maps/TOME_3017_inferred_sigma.dtseries.nii';
varea = '/home/ozzy/Downloads/TOME_3017_cifti_maps/TOME_3017_inferred_varea.dtseries.nii';

% We want to reverse the sign of the polar angle for the righthemisphere as
% they are all positive in the results
angle = cifti_read(angle); 
lefthemiInfo = cifti_diminfo_dense_get_surface_info(angle.diminfo{1}, 'CORTEX_RIGHT');
angle.cdata(lefthemi.ciftilist) = -1*angle.cdata(lefthemi.ciftilist);

% Load eccentricity, sigma, and the Varea maps
eccen = cifti_read(eccen);
sigma = cifti_read(sigma);
varea = cifti_read(varea);
eccen = eccen.cdata;
sigman = sigma.cdata;
varea = varea.cdata; 
angle = angle.cdata;

% Find the indices of V1 and mask other maps with it 
V1 = find(varea.cdata == 1);
