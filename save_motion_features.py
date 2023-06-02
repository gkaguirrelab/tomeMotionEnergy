# Import some general tools 
import itertools,sys,os
from PIL import Image
import numpy as np
from scipy.io import loadmat, savemat

# Import main moten utils 
from moten.utils import (DotDict,
                         iterator_func,
                         log_compress,
                         sqrt_sum_squares,
                         pointwise_square,
                         )
from moten.io import *

# Import edited pymoten functions. These were edited for single filter procesing
current_folder = os.getcwd()
sys.path.append(current_folder)

from pymoten_core_edited import *
from pymoten_pyramids_edited import *

def save_motion_features(video, xysigma_mat, stimulus_fps, temporal_frequency, 
                        spatial_frequency, spatial_direction, singleFilter, 
                        fixed_spatial_envelope, fixed_temporal_envelope, output_mat,
                        spatial_phase_offset=0.0, filter_temporal_width='auto'):
    
    # load video and convert to luminance
    luminance_images = video2luminance(video, nimages=np.inf)
    
    # Get the shape
    nimages, vdim, hdim = luminance_images.shape
    
    # Load the matlab coordinates and save it as an array
    coordinate_set = loadmat(xysigma_mat)
    coordinate_set = coordinate_set[list(coordinate_set)[-1]]
    
    # Loop throught the coordinates and get x,y,sigma. PERFORM CONVERSION.
    results = np.zeros(len(coordinate_set), nimages)
    for i in range(len(coordinate_set)):
        cx = coordinate_set[i][0]
        cy = coordinate_set[i][1]
        sigma = coordinate_set[i][2]
        
        # Create the filter
        filt = MotionEnergyPyramid(stimulus_vhsize=(vdim, hdim),
                                   stimulus_fps=stimulus_fps,
                                   temporal_frequencies=[temporal_frequency],
                                   spatial_frequencies=[spatial_frequency],
                                   spatial_directions=[spatial_direction],
                                   sf_gauss_ratio=0.6,
                                   max_spatial_env=0.3,
                                   filter_spacing=3.5,
                                   tf_gauss_ratio=10.,
                                   max_temp_env=0.3,
                                   include_edges=False,
                                   spatial_phase_offset=spatial_phase_offset,
                                   filter_temporal_width=filter_temporal_width,
                                   singleFilter=singleFilter,
                                   cx=cx,
                                   cy=cy,
                                   fixed_spatial_envelope=sigma,
                                   fixed_temporal_envelope='none')
        
        # Calculate the motion energy for the filter
        feature = filt.project_stimulus(luminance_images)
        results[i] = feature
    
    # Save mat results 
    results = {'results':results}
    savemat(output_mat, results)