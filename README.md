# DWI Processing

These scripts process diffusion dicoms into GM, CSF, and WM-FOD images suitable for use in tractography, masks, and FA and MD images.

The script `diffusion/process-single-shell.sh` will process single-shell reverse phased DWI.

The script `diffusion/process-multishell.sh` will process multi-shell reverse phased DWI. 


## Installation

Run ./install before first running the script. Note XCode must be installed already if on Apple.

If you have existing installations of Mrtrix SSMT you can override locations in exe-paths, or (better) you can shortcut installation by creating softlinks in this source directory. See exe-paths for the expected paths.

## Structuring your data

Data should be structured as follows:

```
<study-directory>/dicoms/<subject-id>/diffusion_ap/*.dcm
<study-directory>/dicoms/<subject-id>/diffusion_pa/*.dcm
<study-directory>/dicoms/<subject-id>/t1/*.dcm
```


Results are output to:

```<study-directory>/diffusion/<subject-id>/```

For example for data:

```
/home/lee/my-study/dicoms/mike-jones/diffusion_ap/*.dcm
/home/lee/my-study/dicoms/mike-jones/diffusion_pa/*.dcm
```

`process-single-shell.sh --study-dir /home/lee/my-study/ --subj mike-jones`

Would produce:

```
/home/lee/my-study/diffusion/mike-jones/fa.nii.gz
/home/lee/my-study/diffusion/mike-jones/md.nii.gz
/home/lee/my-study/diffusion/mike-jones/fod-wm.mif.gz
etc
```
