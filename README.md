# Prototype for Sulfur OS : Non-Bare-Metal User-Space Control-Flow Attestation
This repository contains the prototype implementaion for our paper Non-Bare-Metal User-Space Control-Flow Attestation. 

# Development & Testing Environment
We built our proof-of-concept implementation on top of OP-TEE and the ARM FVP platform. The performance numbers reported in the paper were obtained by evaluating on a Raspberry Pi 3 B+. For artifact evaluation, we provide the FVP-based setup. To reproduce the exact performance results, however, the system must be run on Raspberry Pi 3 B+. We are submitting a packaged OP-TEE setup as a zip file, since the OP-TEE and FVP versions have changed since our experiments.

# Steps to Build and run
Please download the artifact zip from https://drive.usercontent.google.com/download?id=1Kuoln4mEMCSg6197LQUBK7S_fhh_MJ3M&export=download&authuser=0.

The archive is approximately 5 GB in size, so we were unable to upload it to GitHub.
### Step 1: Place the Artifact in the Project Directory
This step copies the artifact.zip file into the project directory.
```bash
cp ~/Downloads/artifact.zip ~/Sulfur/
```

### Step 2: Make Scripts Executable
```bash
chmod 777 install.sh
chmod 777 build.sh
```
### Step 3: Install Prerequisites
This step installs all the required prerequisites and unzips the artifact.zip into the project directory.
```bash
sudo ./install.sh
```
### Step 4: Build and Run FVP
Running build.sh will build the required components.

Baseline mode: Builds the vanilla OP-TEE setup for FVP with the standard ARM Trusted Firmware, and Linux kernel.

Sulfur mode: Builds the OP-TEE setup for FVP with modified ARM Trusted Firmware, and Linux kernel used in Sulfur.



At the end of the build, the FVP terminals will be launched.

Additionally, the artifact/ folder contains a run.sh script, which is copied into the FVP filesystem during setup. This script runs the two benchmarks: lmbench and embench.
To build OP-TEE and FVP, run:

```bash
sudo sh ./build.sh baseline   # for baseline mode
sudo sh ./build.sh sulfur     # for sulfur mode
```
### Step 5: Run Benchmarks in FVP
The benchmarks can be run and tested via the FVP XTerminals. 
Once the FVP is booted, go to terminal 0 and log in as "root". 

Run the following command in FVP terminal 0 to execute the two benchmarks (lmbench and embench) for the selected mode:

```bash
cd /usr/bin
sh run.sh [baseline|sulfur]
```

## Implementation details
We developed a proof-of-concept implementation of our system as described in the paper. Most modifications were made to Linux and ARM Trusted Firmware (ARM-TF). In Linux, we added support for system configuration protection, introduced Sulfur gates to save and restore process context, and simulated page fault overheads by invoking SMC calls in the page fault handler. In ARM-TF, we implemented the Sulfur monitor handler, which writes to system registers and enforces policies. On the Raspberry Pi 3B+ platform, we were able to map Normal World (NW) memory into the Secure World (SW) and update NW memory from ARM-TF via the Sulfur monitor. For FVP, we applied similar changes in ARM-TF to enable mapping of NW memory into SW. While we confirmed that the mapping was successful, direct access to NW memory from ARM-TF was not possible.

System configuration protection was implemented by replacing MSR instructions with SMC calls, except for a few corner cases where replacement was not feasible. In the SMC handler, we defined policy logic prototypes for each system register. As a prototype, we implemented a policy for SCTLR_EL1, which verifies whether the WXN (Write XOR eXecute) bit is enabled. If the check passes, the write is permitted and performed by the SMC handler, ensuring the kernel cannot directly modify system registers. For special registers requiring specific configurations, we invoked empty SMC calls to EL3 to correctly account for overhead, while the actual writes were still performed in Linux. Similarly, when other special registers are needed, parameters can be passed between Linux and ARM-TF to enable them, and policies can be extended accordingly.

Our system was developed on FVP and evaluated on a Raspberry Pi 3B+. To reproduce the performance numbers reported in the paper, the system must be run on a Raspberry Pi 3B+.

## Accessing FVP Terminals Without GUI

When we run FVP using build.sh script, it generally spawns 4 FVP terminals. To access these terminals, a GUI is usually required. After booting up, you can run benchmark scripts in FVP terminal 0, where Linux boots.

If a GUI is not available, you can still access these terminals via telnet. For example, when running FVP on a local machine, we used the following command (here, port 5000 corresponds to FVP terminal 0):
```bash
telnet localhost 5000
```
After Linux boots, you can run this command in any terminal to access FVP terminal 0. If you are unable to access the Linux terminal on port 5000, try other ports such as 5001, 5002, or 5003.

## Solution Patch and Explanation
The issue arises due to two primary reasons. First, the project was compiled using Python 2, so please ensure that Python 2 is installed on your system. Second, all compiler warnings are currently treated as errors, which needs to be corrected so that warnings are treated as warnings only.

To resolve this, please run the following commands. We will first remove the artifact folder and unzip it again to avoid any cached environment conflicts.

It is assumed that you are currently in the Sulfur directory.
```bash
sudo rm -rf artifact
sudo unzip artifact.zip
cd artifact
sudo sed -i 's/-Werror//g' edk2/BaseTools/Conf/tools_def.template edk2/BaseTools/Source/C/Makefiles/header.makefile
cd ..
```
After completing these steps, you can proceed with Step 4 and onwards.

## Copying our Environment and sources.list
Have to extract this zip and have to run this target,sh

```bash
sudo chmod 777 target.sh
sudo bash target.sh
```


