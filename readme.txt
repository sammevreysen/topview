Vreysen S, Scheyltjens I, Laramée M-E and Arckens L (2017) A Tool for Brain-Wide Quantitative Analysis of Molecular Data upon Projection into a Planar View of Choice. 
Front. Neuroanat. 11:1.
doi: 10.3389/fnana.2017.00001

This repository is provided under MIT license upon refering to the above mentioned paper.

Short manual:

Minimal requirements:
Matlab 2015a with packages Image Processing Toolbox, Statistics and Machine Learning Toolbox and Curve Fitting Toolbox

Optimal preprocessing steps:
- Select slices every 100µm for each animal
- Save your pictures as tiff files for best quality
- Create metadata for each slice: condition, animal, bregma level
- Add the bregma level to the end of the filename: xxxx_100.tif
- Define histological landmarks on each slice. These can be areal borders defined by Nissl stainings which are transferred onto the picture with the actual signal for this slice, 
  or a mark visible with the naked eye on each slice like the midline of the brain and the rhinal fissure (for visual cortex)

To use the software, start the first GUI with the command ISH.
Fill in the general details:
- areas that will be defined (number of histological landmarks is depending on this: #areas + 1)
- Number of layers = 1 (grayscale) or = 3 (RGB when using 3 different markers)
- The color of the signal: Black (brightfield pictures) or White (fluorescent pictures)
- Grid size: the step size you used to select the slices (A low number of missing slices will be automatically interpolated)
- px/mm: how many pixels fit in 1 mm on your picture
- segments: number of segments in lateral-medial axis. We used 30 for the visual cortex, 50 for midline to rhinal fissure topviews.

ISH allows the user to enter each slice hierarchically per condition and per animal:
1) Create a new condition (don't create all conditions at once, create one and add at least one animal)
2) Create a new animal (don't create all animals at once, create one and add at least one slice)
3) Add a slice by selecting its picture. The picture will be loaded and the follow the instructions given above the picture to delineate the borders of the area of interest and to
  assign the histological landmarks for each slice. (Tip: don't make curves that when projected result in overlapping points. In these cases you should rotate the picture upfront)
4) repeat 1-3 for all slices and save your project from time to time
5) When done, press Segmentize (this can take a while, follow the console to see the progress)
6) Extract data (this step opens all pictures in the background and extracts the optical densitiy for each segment)
7) Open the second GUI from the menu Topview > Switch to Topview GUI... 
8) This GUI contains a list of all slices you entered, press the checkbox "Ortho projection" to define the midline for each slice (or in batch using the  menu Batch > Register midline)
9) Press the button mice... to open the next GUI (to reopen a project in which you already reached this step, use the command "managermice({projectname})")
10) This GUI contains an overview of all animals in the project. Use the buttons under the tab Topview projection to create a topview per animal, a topview per animal fitted to the reference map (called called general model or gm) or a topview for each condition
11) Press the button Compare conditions... to start the next GUI
12) This GUI allows you to compare 2 conditions using the pseudo t-test. Select a condition for both conditionA and conditionB (you'll need at least 3 animals per condition!)
13) Check the most right checkbox to start the pseudo t-test calculations (PT-t (~=S²) = not assuming equal variance) and follow the progress in the console
14) When the calculations are done, select 1-tailed activation or deactivation or 2-tailed comparison from the drop down menu and press Draw statistics to visualize the results.