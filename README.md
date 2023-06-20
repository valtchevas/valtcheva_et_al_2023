# valtcheva_et_al_2023
fiber photometry code from valtcheva et al (2023)

0.	Organizing data: Create a path ending in a folder representing one experiment type that contains subfolders (each of which should contain a single .mat file with raw photometry data from one experiment). This path should be assigned to the ‘basepath’ variable found in all codes in this folder.
    •	Note on example file format:
    - .mat files produced by TDT Synapse
    - data should be in a structure so each channel is stored separately
    - signal data is stored in data.Ca
    - control data is stored in data.iso 
    - stimulus data is stored in data.input
    - sampling rate for this dataset is 1017.25 Hz
1.	Run ‘Sti_pulse_extract_all.m’ (which will leverage ‘RF_getPupCall.m’ function). Mid-run, you will need to manually click to choose a threshold for TTL pulses that appear in a pop-up. Post-run, a ‘Pulses’ folder containing a picture of manually identified pulses and new .mat file containing a pulses variable with information about TTLs should appear in the subfolder where your raw photometry data is located.
    •	Note: One common error indicates that there is no valid file in your basepath. We suggest to 1) click ‘files’ variable in your workspace and determine how many files down the list your photometry traces file is and 2) change the first number in your for-loop ranges to that number
2.	Run ‘Peri_sti_signal.m’ this will create a ‘signal_peri.mat’ file containing organized photometry signal surrounding each of your events (e.g., TTL pulses) in the subfolder where your raw photometry data is located.
3.	Run ‘dFoverF_periEvent_all.m’ which will generate delta F/F figures for photometry signal surrounding each event/TTL pulse. Each figure will be saved as a .fig file in the folder where your raw photometry data is located.
4.	Optional: Run ‘get_all_peaks.m’ for peak detection. 
5.	Run ‘group_peri_fig.m’ for all files in a given experiment type to be grouped. Leverages ‘plot_areaerrorbar.m’ function.
6.	Optional: Run ’normed_smoothed_figure.m’.
