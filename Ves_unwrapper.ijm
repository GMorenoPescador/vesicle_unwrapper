// Macro for phase separation of GUV-GPMVs

//creating and entri dialog box for the very basics, based on all the stuff done in "phaseSe" script
//maybe it could also be done with action Bar
// September 2022
// Author:  Guillermo Moreno-Pescador
// email: moreno@nbi.ku.dk

// Line with setting for the unwrapping
#@ Double(Label="Line Width [pixles]", value=15, min=2, max=30, style="slider", persist=false) LWidth
//
//thresholding option
#@ boolean (label="threshold image to remove noisy background?") Masking
#@ String(choices={"Auto-Otsu", "Manual"}, style="list") ThresholdCH1
#@ String(choices={"Auto-Otsu", "Manual"}, style="list") ThresholdCH2
//
//Averaging menu
#@ boolean (label="Do you want to average the intendsity signal?") Avg
#@ String(choices={"Running-Average", "Grouped-frames"}, style="list") Avg_mode
//
//Normalizing
#@ boolean (label="Do you want to Normalize the final results? DO NO TUSE YET") Norm


roiManager("reset");
run("Clear Results");
run("Line Width...", "line="+LWidth);


//original scale of the image
getVoxelSize(width_O, height_O, depth_O, unit_O);
print(width_O);

// GUV contour intensity macro
run("Duplicate...", "title=FusedVesicle.tif duplicate");
setVoxelSize(1, 1, 1, "pixel");
run("Split Channels");


//CHANNEL 2 Vesicle selection %%%%%%%%%%%%%%%%%%%%%%%%%%
selectImage("C2-FusedVesicle.tif"); // we make the fitting in the membrane channel, normally in red 
run("Set... ", "zoom=200 x=105 y=111");

////makes an oval
setTool("elliptical");
waitForUser("Please mark the vesicle and press OK");  

List.setMeasurements;
x = List.getValue("X");
y = List.getValue("Y"); 
a = List.getValue("Major");
b = List.getValue("Minor");
angle = List.getValue("Angle");
getVoxelSize(w, h, d, unit);
drawEllipse(x/w, y/w, (a/w)/2, (b/w)/2, angle);


//CHANNEL 1 Vesicle selection %%%%%%%%%%%%%%%%%%%%%%%%%%
//Also selction of the vesicle for the other channel
selectImage("C1-FusedVesicle.tif");
//run("Subtract Background...", "rolling=150"); // I need to automate this number
run("Set... ", "zoom=200 x=105 y=111");
drawEllipse(x/w, y/w, (a/w)/2, (b/w)/2, angle);


//**********************
//CHANNEL 2     ***********************************
//// flatteining the GUV
selectImage("C2-FusedVesicle.tif");
run("Straighten...", "title=Streched_C2_FusedVesicle.tif");
Streched_C2 = getTitle();
resetMinAndMax // This works for 8 bit images, for 16 or 24 it might not work the same way
getMinAndMax(C2min, C2max);
run("Reslice [/]...", "output=1.000 start=Left avoid");
rename("C2-Sliced_Raw_Vesicle");
Raw_resliced_C2=getImageID();

//In casse we want to eliminate backgorund
if (Masking) {
	selectImage(Streched_C2);
	
//#@ String(choices={"Auto-Otsu", "Manual"}, style="list") ThresholdCH2
print(ThresholdCH2); // controlling what it is in that variable

	if (ThresholdCH2 == "Auto-Otsu") {
			//Mask C_1 auto
			run("Duplicate...", "title=C2_mask duplicate");
			maskIm_C2=getTitle();
			setAutoThreshold("Otsu dark");
			run("Convert to Mask");
		}
		else {
			//Mask C_1 auto
			run("Duplicate...", "title=C2_mask duplicate");
			maskIm_C2=getTitle();
			setAutoThreshold("Default dark");
			run("Threshold...");
			waitForUser("thresdold + click -Apply-");
			run("Convert to Mask");

		}

	//We assume the images are 8bits for now, but later this will be automatic also
	run("Divide...", "value=255"); // to make it binary 0 to 1
	// multipply by a mask C2
	imageCalculator("multiply create", Streched_C2, maskIm_C2);
	rename("C2-masked_streched");
	Masked_Vesicle_C2=getImageID();
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("C2-Masked_Resliced_Vesicle.tif");
	Masked_Resliced_C2=getImageID();
	close("Threshold");
}
else {
	Masked_Resliced_C2=Raw_resliced_C2; // Basically no masking or backgorund removal
	
}

//// %%%%%%%%%%%% Do you want to average the streched GUV signal for mooother intensity plots?
if (Avg) {   // TODO need to add a check in case we do not use the masked version here.
	selectImage(Masked_Resliced_C2);
	
if (Avg_mode == "Running-Average"){
		
		// run the new fancy function
		Masked_C2_averaged = Running_Average(Masked_Resliced_C2); // TODO: need to make sure i plot the kernel number in the window
																// with the trick Kstring= ""+value
		}
		else {
			
		// do the old grouped frames method
//		TODO Funtion coming soon!!!

		}

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//	waitForUser("where is the running average?");
	Masked_Resliced_C2_averaged=getImageID();  // FOR PLOTTING
}

// Normalization ################################################
// TODO make sure Normlizing works properly
// It seems i need to select the streched image and not the resliced for this to work
if (Norm && Avg){
	print("Normalizing C2 max = "+C2max);
	selectImage(Masked_Resliced_C2_averaged);
	run("Duplicate...", "title=Normalized_resliced_avg_C2 duplicate");
	control = floor(C2max);
	Norm_val = ""+control;
	print(C2max);
	print(control);
	print(Norm_val);
	run("Divide...", "value="+Norm_val);
	Norm_C2=getImageID();	// FOR PLOTTING NORMALIZED AVG
	
	}
	else if (Norm) {
	print("Normalizing C2 max = "+C2max);
	selectImage(Masked_Vesicle_C2);
	run("Duplicate...", "title=Normalized_resliced_C2 duplicate");
	floor(C2max);
	run("Divide...", "value="+C2max);
	Norm_C2=getImageID();   // // FOR PLOTTING NORMALIZED
	
	}


////%%%%%%%
//exit //%%
////%%%%%%%



// ######################################################################
//*******************
//CHANEL 1      ************************************
//// flatteining the GUV
selectImage("C1-FusedVesicle.tif");
run("Straighten...", "title=Streched_C1_FusedVesicle.tif");
Streched_C1=getTitle();
resetMinAndMax;
getMinAndMax(C1min, C1max);
run("Reslice [/]...", "output=1.000 start=Left avoid");
rename("C1-Sliced_Raw_Vesicle");
Raw_resliced_C1=getImageID();

//In casse we want to eliminate backgorund
if (Masking) {
	selectImage(Streched_C1);

//#@ String(choices={"Auto-Otsu", "Manual"}, style="list") ThresholdCH1
print(ThresholdCH1); // controlling what it is in that variable

	
if (ThresholdCH1 == "Auto-Otsu") {
			//Mask C_1 auto
			run("Duplicate...", "title=C1_mask.tif duplicate");
			maskIm_C1=getTitle();
			setAutoThreshold("Otsu dark");
			run("Convert to Mask");
		}
		else {
			//Mask C_1 auto
			run("Duplicate...", "title=C1_mask.tif duplicate");
			maskIm_C1=getTitle();
			setAutoThreshold("Default dark");
			run("Threshold...");
			waitForUser("thresdold + click -Apply-");
			run("Convert to Mask");

		}
	//We assume the images are 8bits for now, but later this will be automatic also
	run("Divide...", "value=255"); // to make it binary 0 to 1
	// multipply by a mask C1
	imageCalculator("multiply create", Streched_C1, maskIm_C1);
	rename("C1-masked_streched");
	Masked_Vesicle_C1=getTitle();
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	rename("C2-Masked_Resliced_Vesicle.tif");
	Masked_Resliced_C1=getImageID();
	close("Threshold");
}
else {
	Masked_Resliced_C1=Raw_resliced_C1; // Basically no masking or backgorund removal
	
}

//// %%%%%%%%%%%% Do you want to average the streched GUV signal for mooother intensity plots?
if (Avg) {   // TODO need to add a check in case we do not use the masked version here.
	selectImage(Masked_Resliced_C1);
	
if (Avg_mode == "Running-Average"){
		
		// run the new fancy function
		Masked_C1_averaged = Running_Average(Masked_Resliced_C1); // TODO: need to make sure i plot the kernel number in the window
		
		}
		else {
			
		// do the old grouped frames method
//		TODO Funtion coming soon!!!

		}

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Masked_Resliced_C1_averaged=getImageID();  // FOR PLOTTING
}

//// Normalization ################################################
//// TODO make sure Normlizing works properly
//if (Norm && Avg){
//	print("Normalizing C1 max = "+C1max);
//	selectImage(Masked_Resliced_C1_averaged);
//	run("Duplicate...", "title=Normalized_resliced_avg_C1 duplicate");
//	floor(C1max);
//	run("Divide...", "value="+C1max);
//	Norm_C1=getImageID();	// FOR PLOTTING NORMALIZED AVG
//	
//	
//	else if (Norm) {
//	print("Normalizing C1 max = "+C1max);
//	selectImage(Masked_Resliced_C1);
//	run("Duplicate...", "title=Normalized_resliced_C1 duplicate");
//	floor(C1max);
//	run("Divide...", "value="+C1max);
//	Norm_C1=getImageID();   // // FOR PLOTTING NORMALIZED
//	
//	}
//
//}


// ########## PLOT RESULTS   ##############################

PlotResults();

// ########## FUNCTIONS BELOW   ##############################


//#########################################################
function drawEllipse(x, y, a, b, angle) {	
      beta = -angle * (PI/180);
      X = newArray(360/2+1);
	  Y= newArray(360/2+1);
	  index=0;
      for (i=0; i<=360; i+=2) {
          alpha = i*(PI/180) ;
          X[index] = x + a*cos(alpha)*cos(beta) - b*sin(alpha)*sin(beta);
          Y[index]= y + a*cos(alpha)*sin(beta) + b*sin(alpha)*cos(beta);
		  index+=1;
      }
	  makeSelection("polyline", X, Y);
  }
//############################################################



//#################################################################
function Running_Average(Im1ID) { 
// function description
//###### INPUT= Im1ID is the resliced streched GUV stack image directly - not the resliced one
// Stack Moving Average
//
// This macro does a 3, 5 or 7 slice moving average in the z direction
// of a stack. Note that the first (n-1)/2 and the last (n-1)/2 slices
// of the resulting stack should probably be discarded since the 
// convolving filter averages olong the edge by extending edge pixels,
// causing the first and last slice to be over-weighted.

  k3 = "[0 1 0 0 1 0 0 1 0]";
  k5 = "[0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0]";
  k7a = "[0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1";
  k7b = " 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0]";
  k7 = k7a + k7b;
  Dialog.create("Running Average");
  Dialog.addChoice("Slices to Average:", newArray("3", "5", "7"));
  Dialog.addCheckbox("Keep Source Stack", true);
  Dialog.show;
  n = Dialog.getChoice;
  keep = Dialog.getCheckbox;
  kernel = k3;
  if (n=="5")
      kernel = k5;
  else if (n=="7")
      kernel = k7;
  if (nSlices==1)
      exit("Stack required");
  id1 = Im1ID;
  selectImage(id1);
  // re-slicing may not work if stack is scaled
  setVoxelSize(1, 1, 1, "pixel");
  getMinAndMax(min, max);
  run("Reslice [/]...", "input=1 output=1 start=Top");
  id2 = getImageID;
  if (!keep) {selectImage(id1); close;}
  selectImage(id2);
  run("Convolve...", "text1="+kernel+" normalize stack");
  setMinAndMax(min, max); 
  selectImage(id2);
  run("Rotate 90 Degrees Left");
  run("Flip Vertically");
  nn=""+n;
  run("Duplicate...", "title=RunningAverage_k= "+nn+".tif duplicate");
  Run_Avg_IM=getImageID();
  selectImage(id2);
  close;
  run("Reslice [/]...", "output=1 start=Left avoid");
  return Run_Avg_IM // retund the id of the averaged streched image, this will be usefull for normalization
}
// #############################################################################

//#########################################################
function PlotResults() {
	
//	Channel 1
	if (Avg){
	
	selectImage(Masked_Resliced_C1_averaged);
	print("selected");
	}
	else if (Avg && Norm){
		selectImage(Norm_C1);
	}
	// neccessary for dicing the stack in equalt portions
	getDimensions(Cwidth, Cheight, Cchannels, Cslices, Cframes);
	Odd_Even=4;
	while (Cslices%Odd_Even!=0) {
	Odd_Even = Odd_Even +1;
	}
	print("Slices are a multiple of "+Odd_Even);
//	run("Plot Z-axis Profile"); //getting somewhere// this alos work without the Odd_even thing but the values are different with the new avg function
	run("Grouped Z Project...", "projection=[Average Intensity] group="+Odd_Even);
	Grouped_Resliced_Vesicle_C1 = getTitle();
	run("Plot Z-axis Profile"); //getting somewhere// this alos work without the Odd_even thing but the values are different
	Plot.getValues(C1_xp, C1_yp);
	close();	
	
	
// Channel 2
	if (Avg){
	
	selectImage(Masked_Resliced_C2_averaged);
	}
	
	else if (Avg && Norm){
	selectImage(Norm_C2);
	}
	
//	run("Plot Z-axis Profile"); //getting somewhere
	run("Grouped Z Project...", "projection=[Average Intensity] group="+Odd_Even); // both stacks should be the same size
	Grouped_Resliced_Vesicle_C2 = getTitle();
	run("Plot Z-axis Profile"); //getting somewhere
	Plot.getValues(C2_xp, C2_yp);
	close();

// maybe this for exporting the values 
//Array.show("Channel 1 vS Channel 2", C1_xp, C1_yp, C2_yp);

// Actual plotting
Plot.create("Intensity plots", "Distance [pixel]", "Intensity [au]");
Plot.setLineWidth(4);
Plot.setColor("green");
Plot.add("line", C1_xp, C1_yp);
Plot.setColor("magenta");
Plot.add("line", C2_xp, C2_yp);
Plot.setLegend("Channel 1\tChannel 2", "transparent");

Plot.show();
Plot.setLimitsToFit()
//Fit.showDialog;

}
//############################################################
