# Spikenet

Spikenet is a set of MATLAB tools for spike detection in neural recordings and analysis of network effects. 

Starting with recordings of neurons with voltage sensitive fluorescent dyes, users select a set of ROIs (neurons) for each cover slide. From there, the program extracts an intensity trace for each ROI and identifies potential spikes. The user then sets a threshold for SNR of ΔF/F as well as a rearm time, and the frame numbers for identified spikes are saved to .mat files. Using immunostaining, neurons can be tagged by type (CA1, CA3, DGC, inhibitory). From there, Spikenet includes implementations to calculate several metrics, including STTC (Cutts et al. 2014) and causality metric (Yin et al. 2016).

Relevant Publication: [link to paper here]()

## Usage Guide
### Prerequisites
Matlab is required to run Spikenet. Some functions may not work with versions prior to 2017a. After downloading, be sure to add the folder to your MATLAB path. 

### File Structure
For the program to work, it's important for the files to be in the following format. 
```
experiment
+-- coverslip1
|   +-- area1
    |   +-- brightfield.tiff
    |   +-- video_part_1.tiff
    |   +-- video_part_2.tiff
    |   +-- ...
|   +-- area2
|   +-- ...
```
The names of the files aren't important, but the program relies on the folder structure to group movies and do batch analysis. Every set of movies for the same area on the same cover slip should be in the same folder. In addition to the fluorescent recording, take a brightfield picture of the area in order to select ROIs later.

### Selecting ROIs
Data processing starts with `selectroi_gui.m`. For this step, the user identifies the ROIs for every area recorded. 
1. Start by selecting a brightfield tiff image. 
2. Selecting a fluorescent tiff stack. Either a single video can be selected manually, or 'Import All' will select all other .tiff files in the directory.
3. Make sure the frame rate parameter matches the recording frame rate.
4. Draw all ROIs, then click 'Save ROIs and choose background'.
5. The GUI displays the first frame of the fluorescent tiff stack, circle an area of background.
6. After saving background, repeat for every area that you would like to analyze together.

The output at this step is file in the same directory as the area named `roi-*.mat`, where `*` is the name of the brightfield image selected.

### Spike Detection
After selecting ROIs for all areas to be analyzed, run `batchkmeans_gui.m`. In this section, select the top level folder for the experiment. For each `roi-*.mat` file found, a fluorescent trace is computed for each ROI for each recording. Next, k-means clustering is used to identify possible spikes, subthreshold events, and baseline.

The next step is `thresholding_gui.m`, where possible spikes are filtered based on a minimum SNR of ΔF/F.
1. Select the same folder as the previous section.
2. A histogram of the SNR values is displayed. Set a minimum SNR threshold (make sure to click `Set Threshold`). 
3. Set a re-arm factor, which is the minimum number of frames between spikes. 
4. Preview the selected spikes to check that they match up well with the traces. Adjust parameters as needed.
5. Click `Save Spikes to File` which will save the data to `spikes-*.mat` file, where `*` is the name of the recording, in the same directory as the recording.

### Labeling ROIs
If you know the types of the neurons, use `LabelRoi/labelroi.m`.
1. Select a folder for an area after completing ROI selection. There should be a `label-*.png` file in the folder.
2. The brightfield image is displayed with the selected ROIs and numbers. For each ROI, select the type.

### Metrics
Spikenet contains implementations for various metrics that are calculated from the spike data. Find the GUIs for these in the associated folder.

#### STTC (Cutts et al. 2014)
1. Run `sttc_gui.m` and select a folder. The program will search for `spikes-*.mat` files and group by the area that they represent.
2. Set the window size in `STTC Max Lag (ms)`.
3. Select either an area or an individual file in the file selector and click `Update STTC Heatmap`. In the heat map, each square is clickable. If an area is selected, a crosscorrelogram between the the ROIs is displayed. If a file is selected, the spikes for the two ROIs are shown instead. If a square in the top-right triangle is white, it indicates that one of those cells is non-firing.
4. `Export STTC to Excel` will calculate the pairwise STTC for every single area in the folder selected.

#### Area Under Curve (AUC)
AUC computes the integral for action potentials and exports the result to Excel. Start by running `AUC/auc_gui.m` and choosing a folder.

#### XCI
The XCI between neurons A and B is the fraction of A's spikes that have a corresponding spike in B within a specified lag range. Run `XCI/xci_gui.m` to get started.
1. Select a folder for processing.
2. Specify filter parameters.
    a. Monosynaptic lag range
    b. Minimum frequency - any cell with a lower frequency will be considered nonfiring and excluded from analysis.
    c. XCI Threshold - this is the minimum XCI threshold to assume a connection between two neurons.
    d. # Histogram Bins
    e. Filter by cell type - areas can be excluded by whether or not they contain a type of cell.

After analysis is complete, the results can be exported to an Excel file.

Based on the inferred functional connections, additional calculations are made to assess the frequency at types of neurons connect to each other.

#### Causality Metric (Yin et al. 2016)
Run `CausalityMetric/cm_gui.m` and select a folder. The GUI and calculations made are nearly identical to that of XCI, except the pairwise causality metric is used to infer functional connections instead.


## Authors

* Kaveh Karbasi
* Patrick Zhang
* Kate Sanders

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
