/* Hi users, 
 * 
 * To aid in making a filter that can select everything you want to analyse in the ROI manager
 * This macro allows you to easily select the criteria your objects need to fulfil
 * It subsequently writes a macro in a user chosen location by a user chosen name that can be recalled at any given time
 * by implementing two lines of code. 
 * 
  	run("Install...", "install=["  FILTERNAME.txt   ");
	run( FILTERNAME );
 *
 * This will install the macro and run it on the active ROI manager
 * 
 * Written by Joost Willemse @ Leiden University
 * Contact me @ jwillemse at biology.leidenuniv.nl
 
*/

macro "Criteria selector..." {	//1
	Criteria=newArray(); // to save the criteria
	items=newArray("","Area", "Aspect_Ratio", "Roundness","Circularity", "Mean", "Standard_Deviation", "Modal", "Median", "Max", "Min","Integrated_Density", "Solidity", "Perimeter","Area_fraction", "Major_axis", "Minor_Axis", "Axis_Angle", "Major_Feret", "Minor_Feret", "Feret_Angle"); // selection criteria
	Choices=newArray("","And","Or");//choice menu for and and or of combinations
	MC=1;
	TString="";
	Counter=0
	
	while (MC==1){ //2
		Dialog.create("ROI filtering"); //User input dialogbox created
		Dialog.addMessage("                                                        Select the bottom and upper limits of objects that need to be kept.\n \n                                                        All input must be numeric.\n                                                        Aspect Ratio, Roundness, Circularity, Area fraction, and Solidity\n                                                        must be between 0 and 1.\n                                                       ==================================================== \n                                                                                                                              Lower  Upper");
		
		Dialog.addChoice("1st criterium", items, "Area");
		Dialog.setInsets(-28, 140, 0);
		Dialog.addNumber("",0 ,0,5,"");
 //lower 1st criterium
		Dialog.setInsets(-28, 190, 0);
		Dialog.addNumber("", 0,0,7,"");
 //upper 1st
		Dialog.setInsets(-32, 250, 0);
		Dialog.addChoice("", Choices, "");
 //and or or
		
		Dialog.addChoice("2nd criterium", items, "");
		Dialog.setInsets(-28, 140, 0);
		Dialog.addNumber("", 0,0,5,"");
 //lower 2nd
		Dialog.setInsets(-28, 190, 0);
		Dialog.addNumber("", 0,0,7,"");
 // upper 2nd
		Dialog.setInsets(-32, 250, 0);
		Dialog.addChoice("", Choices, "");
 // and or or
		
		Dialog.addChoice("3rd criterium", items, "");
		Dialog.setInsets(-28, 140, 0);
		Dialog.addNumber("", 0,0,5,"");
 // lower 3rd
		Dialog.setInsets(-28, 190, 0);
		Dialog.addNumber("", 0,0,7,"");
// upper 3rd
		Dialog.setInsets(0, 180, 0);
		
		Dialog.addCheckbox("Do you want to add more criteria", false);
		if (Counter==0){ //Asks for a directory to store the filter only the first time		
			Dialog.addString("Filtername: ","Filter",38);
			dir1 = getDirectory("Choose Storage directory for the created filter");
		}
		//Dialog.setInsets(top, left, bottom)
		Dialog.show();
		
		C1 = Dialog.getChoice();
		C1B = Dialog.getNumber();
		C1U = Dialog.getNumber();
		C1C = Dialog.getChoice();								
		
		C2 = Dialog.getChoice();
		C2B = Dialog.getNumber();
		C2U = Dialog.getNumber();
		C2C = Dialog.getChoice();
		
		C3 = Dialog.getChoice();	
		C3B = Dialog.getNumber();
		C3U = Dialog.getNumber();
		MC = Dialog.getCheckbox();

		if (Counter==0){ //Asks for a filter name only the first time
			Fname=Dialog.getString();
		}

		if (C1C==""){ //3 This is to write the correct if functions based on the user selected input
			Stringp2="("+ C1+"<"+C1B+"||"+C1+">"+C1U+")";
		} else if (C2C=="" && C1C=="And"){
			Stringp2="(("+ C1+ "<" + C1B+ "||" +C1+ ">" + C1U+ ")||(" + C2 + "<" +C2B + "||" + C2 + ">" + C2U+"))";		
		} else if (C2C=="" && C1C=="Or"){
			Stringp2="(("+ C1 + "<" + C1B+ "||" + C1 +">" + C1U + ")&&(" + C2 +"<" + C2B+"||"+ C2 +">" +C2U+ "))";
		} else if (C2C=="And" && C1C=="Or"){
			Stringp2="((("+ C1 + "<" + C1B + "||" + C1 + ">" + C1U + ")&&(" + C2 + "<" + C2B + "||" + C2 + ">" + C2U + "))||( " + C3 + "<" + C3B + "||" + C3 + ">" + C3U +"))";
		} else if (C2C=="And" && C1C=="And"){
			Stringp2="((("+ C1+ "<" + C1B + "||" + C1 + ">" + C1U+ ")||(" + C2 + "<" + C2B + "||"+ C2 + ">" + C2U + "))||(" + C3 + "<" + C3B + "||" + C3 + ">" + C3U +"))";
		} else if (C2C=="Or" && C1C=="And"){
			Stringp2="(((" + C1 + "<" + C1B + "||" + C1 + ">" + C1U + ")||(" + C2 + "<" + C2B + "||" + C2 + ">" + C2U + "))&&(" + C3 + "<" + C3B + "||" + C3 + ">" + C3U + "))";
		} else if (C2C=="Or" && C1C=="Or"){
			Stringp2="(((" + C1 + "<" + C1B + "||" + C1 + ">" + C1U + ")&&(" + C2 + "<" + C2B + "||" + C2 + ">" + C2U + "))&&(" + C3 + "<" + C3B + "||" + C3 + ">" + C3U + "))";
		} //2
	
		TString=TString+Stringp2;

		Counter=Counter+1;

		if (MC==1){ //3
			TString=TString+"\n		||\n		";
		} //2
	} //1

	/*This part writes all things to filter on
 and part of the filtering macro*/
	Stringp0="setBatchMode(true);\nif (isOpen(\"Results\")) { \n	selectWindow(\"Results\"); \n	run(\"Close\"); \n} \nrun(\"Set Measurements...\", \"area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack redirect=None decimal=2\");\nn = roiManager(\"count\");\nfor (a=0;a<n;a++){\n	roiManager(\"Select\", a);\n	run(\"Measure\");\n}\n";
	Stringp1="n=roiManager(\"count\");\nfor (b=0;b<n;b++){\n	Area = getResult(\"Area\",n-b-1);\n	Aspect_Ratio = getResult(\"AR\",n-b-1);\n	Roundness = getResult(\"Round\",n-b-1);\n	Mean = getResult(\"Mean\",n-b-1);\n	Standard_Deviation = getResult(\"StdDev\",n-b-1);\n	Modal = getResult(\"Mode\",n-b-1);\n	Median = getResult(\"Median\",n-b-1);\n	Max = getResult(\"Max\",n-b-1);\n	Min = getResult(\"Min\",n-b-1);\n	Integrated_Density = getResult(\"IntDen\",n-b-1);\n	Solidity = getResult(\"Solidity\",n-b-1);\n	Perimeter = getResult(\"Perim.\",n-b-1);\n	Area_fraction = getResult(\"%Area\",n-b-1);\n	Major_Axis = getResult(\"Major\",n-b-1);\n	Minor_Axis = getResult(\"Minor\",n-b-1);\n	Axis_Angle = getResult(\"Angle\",n-b-1);\n	Major_Feret = getResult(\"Feret\",n-b-1);\n	Minor_Feret = getResult(\"MinFeret\",n-b-1);\n	Feret_Angle = getResult(\"FeretAngle\",n-b-1);\n	Circularity =getResult(\"Circ.\",n-b-1);\n	if(\n		";	
	Stringp3=")\n	{\n		roiManager(\"select\", n-b-1);\n		roiManager(\"Delete\");\n		IJ.deleteRows(n-b-1, n-b-1);\n	}\n}";
	TestString=Stringp0+Stringp1+TString+Stringp3;
 //combining the various parts of the macro string
	
	showText(TestString);
 //showing the macro string
	saveAs("Text", dir1+"\\"+Fname+".txt");
 //saving the macro string
	run("Install...", "install=[" + dir1+"\\"+Fname + ".txt]");
 // installing the composed macro
	run(Fname);
 // running the macro
}	//0


