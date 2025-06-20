# DWI Processing

These scripts process diffusion dicoms into FA, MD, and GM/CSF/WM-FOD images suitable for use in tractography, as well as some additions including kurtosis metrics, aligned T1s, and brain masks. 

The script `main.sh` will let you pick a pipeline to run. This is what is executed by default in apptainer and docker. More information on the scripts is below.

## Local Installation

### Install

Run `./install.sh` to install dependencies (locally - will not affect what is in your `PATH`). Note XCode and FSL must be installed already if on Apple.

If you have existing installations of Mrtrix SSMT, Ants, and HD-BET you can override locations in exe-paths, or (better) you can shortcut installation by creating softlinks in this source directory. See `exe-paths.sh` for the expected paths.

### Run

Run `./main.sh` to see options.

## Apptainer (Singularity) Installation

### Build

On a cluster, run
```
/full/path/to/reid-diffusion-basics/install/build-singularity-slurm.sh
```

This submits a job to slurm to build the container. It takes about 2 hours.

Once the sif file has been built, the rest of this repository can be delete.

### Run

```
apptainer run --cleanenv --no-home --nv --bind /data/ /path/to/reid-diffusion-basics.sif <arguments>
```

See "The Pipelines" below to see what you need to enter in place of `<arguments>`

## Docker Installation

### Build

Build with:

```
docker build /full/path/to/reid-diffusion-basics/
```

This can take 2 hours to run, depending on your system.

### Run

Run will depend on how you would like to bind to directories on your computer. See "The Pipelines" below to see which non-docker arguments you will need.

## The Pipelines

The container contains several pipelines. Please choose the appropriate one based on your data and use case.

### Process Single Shell

The script `process-single-shell` will process single-shell reverse phased DWI.

#### Required Inputs

This requires dicoms for reverse-phase encoded diffusion data. There should be one AP acquisition and one separate PA acquisition. These images must match in all regards, except the number of b0s, the number of directions acquired, and which directions were acquired. In principle, the pipeline has a means of processing non-reverse phase encoded data if you have a distortion-free (i.e. scanner-corrected) b0 image but this is not "officially supported" - it is up to you to hunt through the code to get this to work.

Suboptimal results or a pipeline error may occur if either acquisition has fewer than 20 directions, or poorly distributed directions. There is no known workaround with these scripts in such a scenario.

Images should have a b value between 2000 and 3000.

The pipeline assumes that partial fourier has not been employed (i.e. it conducts gibbs-artefact removal without checking for appropriateness).

Data should be structured as follows:

```
<study-directory>/dicoms/<subject-id>/diffusion_ap/*.dcm
<study-directory>/dicoms/<subject-id>/diffusion_pa/*.dcm
```

e.g.

```
/data/my-study/dicoms/subj-001/diffusion_ap/*.dcm
/data/my-study/dicoms/subj-001/diffusion_pa/*.dcm

/data/my-study/dicoms/subj-002/diffusion_ap/*.dcm
/data/my-study/dicoms/subj-002/diffusion_pa/*.dcm

```

#### Outputs

Results for diffusion pipelines are output to:

```<study-directory>/diffusion/<subject-id>/```

For example for input data:

```
/home/lee/my-study/dicoms/mike-jones/diffusion_ap/*.dcm
/home/lee/my-study/dicoms/mike-jones/diffusion_pa/*.dcm
```

`diffusion/process-single-shell.sh --study-dir /home/lee/my-study/ --subj mike-jones`

Would produce:

```
/home/lee/my-study/diffusion/mike-jones/fa.nii.gz
/home/lee/my-study/diffusion/mike-jones/md.nii.gz
/home/lee/my-study/diffusion/mike-jones/fod-wm.mif.gz
etc
```

#### Processing Stages

Check the scripts for up to date details on processing. At the time of writing this readme the basic steps were:

1. Preprocessing
    1. Dicom to Nifti conversion, and concatenation of sequences
    1. Denoising (MRtrix)
    1. Gibbs artefact removal (MRtrix)
    1. Concatenation with undistored B0s (only if supplied for distortion correction in absence of reverse-phase encoding)
    1. Eddy Correction (FSL). This includes head motion, susceptibility correction, and eddy current correction. Note that Eddy currents are not present in several dual-spin-echo UCSF sequences.
    1. Skull stripping (HD-BET)
    1. Bias Field Correction (MRtrix/ANTs)
1. Single-shell Multiple Tissue FOD calculation (see Dhollander et al)
1. Tensor Metric Calculation (MRtrix)


### Process Multishell

The script `process-multishell` will process multi-shell reverse phased DWI. 

#### Required Inputs

This requires dicoms for reverse-phase encoded diffusion data. There should be one AP acquisition and one separate PA acquisition. Each should contain many shells. These images must match in all regards, except the number of b0s, the number of directions acquired per shell/overall, and which directions were acquired per shell. 

Suboptimal results or a pipeline error may occur if the highest shell has fewer than 20 directions per acquisition, or the highest shell has poorly distributed directions. There is no known workaround with these scripts in such a scenario.

The highest shell should be b=2000 or higher if tractography is the goal. Ideally, include a shell around b=1000 for FA measurements. For Kurtosis, use a sequence designed by Lee Reid.

The pipeline assumes that partial fourier has not been employed (i.e. it conducts gibbs-artefact removal without checking for appropriateness).


Data should be structured as follows:

```
<study-directory>/dicoms/<subject-id>/diffusion_ap/*.dcm
<study-directory>/dicoms/<subject-id>/diffusion_pa/*.dcm
```

e.g.

```
/data/my-study/dicoms/subj-001/diffusion_ap/*.dcm
/data/my-study/dicoms/subj-001/diffusion_pa/*.dcm

/data/my-study/dicoms/subj-002/diffusion_ap/*.dcm
/data/my-study/dicoms/subj-002/diffusion_pa/*.dcm

```

#### Outputs

Outputs are similar to the single-shelled output, but also include kurtosis measurements where possible.

#### Processing Stages

Check the scripts for up to date details on processing. At the time of writing this readme the basic steps were:

1. Preprocessing
    1. Dicom to Nifti conversion, and concatenation of sequences
    1. Denoising (MRtrix)
    1. Gibbs artefact removal (MRtrix)
    1. Concatenation with undistored B0s (only if supplied for distortion correction in absence of reverse-phase encoding)
    1. Eddy Correction (FSL). This includes head motion, susceptibility correction, and eddy current correction. Note that Eddy currents are not present in several dual-spin-echo UCSF sequences.
    1. Skull stripping (HD-BET)
    1. Bias Field Correction (MRtrix/ANTs)
1. Tensor Metric Calculation (MRtrix)
1. Kurtosis Metric Calculation (MRtrix - experimental).
1. Multi-shell Multiple Tissue FOD calculation (MRtrix)


### T1 To Diffusion

The script `t1-to-diffusion` will process T1 dicoms and align them to already processed diffusion data from the scripts above. This includes N4 Bias correction and HD-BET skull stripping.


#### Inputs

A diffusion script must be run first for this participant. 

Dicoms for T1 images should appear in:

```
<study-directory>/dicoms/<subject-id>/t1/*.dcm
```

#### Outputs

This script will output the

* Raw T1
* Bias corrected T1
* Brain mask
* T1 aligned to the diffusion space
* An ANTs matrix for a rigid transform between the T1 and diffusion space

to
```
<study-directory>/structurals/<subject-id>/
```
