# DWI Processing

The script `process-single-shell.sh` will process single-shell reverse phased DWI into GM, CSF, and WM-FOD images suitable for use in tractography. 

The script `process-multishell.sh` will process multi-shell reverse phased DWI into GM, CSF, and WM-FOD images suitable for use in tractography. 

Run ./install before first running the script. Note XCode must be installed already if on Apple.

Note that installation of Mrtrix and mrtrix ssmt is not currently implemented in the install script. See exe-paths to set the latter.