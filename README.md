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

## Docker Installation

### Build

Build with:

```
docker build /full/path/to/reid-diffusion-basics/
```

This can take 2 hours to run, depending on your system.

### Run

Run will depend on how you would like to bind to directories on your computer.

## The pipelines

### Process Single Shell

The script `process-single-shell` will process single-shell reverse phased DWI.

#### Required Inputs

This requires dicoms for reverse-phase encoded diffusion data. There should be one AP acquisition and one separate PA acquisition. These images must match in all regards, except the number of b0s, the number of directions acquired, and which directions were acquired. 

Suboptimal results or a pipeline error may occur if either acquisition has fewer than 20 directions, or poorly distributed directions. There is no known workaround with these scripts in such a scenario.

Images should have a b value between 2000 and 3000.

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

### Process Multishell

The script `process-multishell` will process multi-shell reverse phased DWI. 

#### Required Inputs

This requires dicoms for reverse-phase encoded diffusion data. There should be one AP acquisition and one separate PA acquisition. Each should contain many shells. These images must match in all regards, except the number of b0s, the number of directions acquired per shell/overall, and which directions were acquired per shell. 

Suboptimal results or a pipeline error may occur if the highest shell has fewer than 20 directions per acquisition, or the highest shell has poorly distributed directions. There is no known workaround with these scripts in such a scenario.

The highest shell should be b=2000 or higher if tractography is the goal. Ideally, include a shell around b=1000 for FA measurements. For Kurtosis, use a sequence designed by Lee Reid.

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
