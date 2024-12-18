#!/bin/bash 

fail () { 
 echo Execution aborted. 
 read -n1 -r -p "Press any key to continue..." key 
 exit 1 
}

# "name" and "dirout" are named according to the testcase

# change "name" according to the theory you want to simulate
# export name=CaseSolitaryWave_Rayleigh
export name=CaseSolitaryWave_Boussinesq
# export name=CaseSolitaryWave_KdV
export dirout=${name}_out
export diroutdata=${dirout}/data

# "executables" are renamed and called from their directory


export dirbin=../../../bin/linux
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${dirbin}
#export gencase="${dirbin}/GenCase_linux64"
export gencaseMkWord="${dirbin}/GenCase_MkWord_linux64"
export dualsphysicscpu="${dirbin}/DualSPHysics5.2CPU_linux64"
export dualsphysicsgpu="${dirbin}/DualSPHysics5.2_linux64"
export boundaryvtk="${dirbin}/BoundaryVTK_linux64"
export partvtk="${dirbin}/PartVTK_linux64"
export partvtkout="${dirbin}/PartVTKOut_linux64"
export measuretool="${dirbin}/MeasureTool_linux64"
export computeforces="${dirbin}/ComputeForces_linux64"
export isosurface="${dirbin}/IsoSurface_linux64"
export flowtool="${dirbin}/FlowTool_linux64"
export floatinginfo="${dirbin}/FloatingInfo_linux64"
export tracerparts="${dirbin}/TracerParts_linux64"

option=-1
 if [ -e $dirout ]; then
 while [ "$option" != 1 -a "$option" != 2 -a "$option" != 3 ] 
 do 

	echo -e "The folder "${dirout}" already exists. Choose an option.
  [1]- Delete it and continue.
  [2]- Execute post-processing.
  [3]- Abort and exit.
"
 read -n 1 option 
 done 
  else 
   option=1 
fi 

if [ $option -eq 1 ]; then
# "dirout" to store results is removed if it already exists
if [ -e ${dirout} ]; then rm -r ${dirout}; fi

# CODES are executed according the selected parameters of execution in this testcase

${gencaseMkWord} ${name}_Def ${dirout}/${name} -save:all
if [ $? -ne 0 ] ; then fail; fi

${dualsphysicsgpu} -gpu ${dirout}/${name} ${dirout} -dirdataout data -svres
if [ $? -ne 0 ] ; then fail; fi

fi

if [ $option -eq 2 -o $option -eq 1 ]; then
export dirout2=${dirout}/particles
${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartFLuid -onlytype:-all,+fluid
if [ $? -ne 0 ] ; then fail; fi

${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartPiston -onlytype:-all,+moving
if [ $? -ne 0 ] ; then fail; fi

${partvtkout} -dirin ${diroutdata} -savevtk ${dirout2}/PartFluidOut -SaveResume ${dirout2}/_ResumeFluidOut
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/measuretool
${measuretool} -dirin ${diroutdata} -points wg_x81.txt -onlytype:-all,+fluid -elevation -savecsv ${dirout2}/eta_x81
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/measuretool
${measuretool} -dirin ${diroutdata} -points wg_x82.txt -onlytype:-all,+fluid -elevation -savecsv ${dirout2}/eta_x82
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/measuretool
${measuretool} -dirin ${diroutdata} -points wg_x83.txt -onlytype:-all,+fluid -elevation -savecsv ${dirout2}/eta_x83
if [ $? -ne 0 ] ; then fail; fi


export dirout2=${dirout}/measuretool
${measuretool} -dirin ${diroutdata} -points wg_hx.txt -onlytype:-all,+fluid -elevation -savecsv ${dirout2}/eta_full -elevationoutput:pos -files:200-300:50
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/surface
${isosurface} -dirin ${diroutdata} -saveslice ${dirout2}/Slices 
if [ $? -ne 0 ] ; then fail; fi

fi
if [ $option != 3 ];then
 echo All done
 else
 echo Execution aborted
fi

read -n1 -r -p "Press any key to continue..." key
