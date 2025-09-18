# Prototype for Sulfur OS : Non-Bare-Metal User-Space Control-Flow Attestation
This repository contains the prototype implementaion for our paper Non-Bare-Metal User-Space Control-Flow Attestation. 

# Development & Testing Environment
We build our proof-of-concept implementation on top of OPTEE and FVP. The numbers reported in the paper were by evaluating on Rpi. For artifact evaluation, we are submitting the FVP. Though for reproducing the performance numbers, the system must be run on Rpi 3 B+. We are submitting a zip of our OPTEE setup because the OPTEE and FVP versions have been changed.

# Steps to Build and run
Please download the artifact zip from (https://drive.usercontent.google.com/download?id=1Kuoln4mEMCSg6197LQUBK7S_fhh_MJ3M&export=download&authuser=0)
Since it is quite big, we could not push it on github.


1. Copy the downloaded ZIP file into the `Sulfur` project directory.

```bash
cp ~/Downloads/artifact.zip ~/Sulfur/
```
2. Give execute permissions to the build scripts:
```bash
chmod 777 install.sh
chmod 777 build.sh
```
3. Run the installer script to install all prerequisites.
```bash
sudo ./install.sh
```
4. Run build.sh to build OPTEE and FVP. Invoke this script with either "baseline" or "sulfur" to build baseline and sulfur respectively.

```bash
sudo ./build.sh baseline/sulfur 
```

5. The benchmarks can be run and tested via the FVP Xterminals. 
    3.1 Once the FVP is booted up, Go to terminal 0 and login as with "root"
    3.3 Run the following command in FVP terminal 0.

```bash
cd /usr/bin
sh run.sh [baseline|sulfur]
```

## Implementation details
We have implemented a proof-of-concept implementation of our system as discussed in the paper. Most of the implementatiom changes were made to Linux and ARM Trusted Firmware. In Linux we have added support for system configuration protection, Sulfur gates to save/restore process context, and simulated the page fault overheads by making SMC in page fault handler. In ARM TF, We have added our sulfur monitor handler, which writes the system registers and checks policies. We were able to map the NW memmory to SW and update the NW memory from ARM-TF (sulfur monitor) on Rpi 3B+ platform. For FVP, We have made the changes in ARM TF for mapping NW memory to SW. We verified that the memory is being mapped,  however, we were not able to access the NW memory from ARM TF. 

We have implemented protection for System configuration as discussed below. 
We replaced MSR instructions with SMC calls. There are some corner cases where we were unable to replace those calls. In the SMC handler, we have defined policy logic prototypes for each register.
We implemented a prototype policy for SCTLR_EL1, which checks if the WXN (Write XOR eXecute) bit is enabled or not. If the policy check passes, then we allow the write, and the write is performed from the SMC handler. This ensures that the kernel is unable to directly write to any system registers.
There are some special registers that require specific configurations to be enabled. In our implementation, we invoked an empty SMC call to EL3 to account for the correct overhead, and we are writing to that register from Linux.Similarly, if other special registers are required, we can provide the appropriate parameters to Linux and to ARM Trusted Firmware to enable them, and we can also add them into the policy.

Our system is developed on FVP and we ran and evaluated on RPi 3. To reproduce the numbers reported in the paper, the system must be run on Rpi 3 B+. 

## Accessing FVP Terminals Without GUI

When we run FVP using build.sh script, it generally spawns 4 FVP terminals. To access these terminals, a GUI is usually required. After booting up, you can run benchmark scripts in FVP terminal 0, where Linux boots.

If a GUI is not available, you can still access these terminals via telnet. For example, when running FVP on a local machine, we used the following command (here, port 5000 corresponds to FVP terminal 0):
```bash
telnet localhost 5000
```
After Linux boots, you can run this command in any terminal to access FVP terminal 0. If you are unable to access the Linux terminal on port 5000, try other ports such as 5001, 5002, or 5003.
