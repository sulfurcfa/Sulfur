# Prototype for Sulfur OS : Non-Bare-Metal User-Space Control-Flow Attestation
This repository contains the prototype implementaion for our paper Non-Bare-Metal User-Space Control-Flow Attestation. 

# Development & Testing Environment
We build our proof-of-concept implementation on top of OPTEE and FVP. The numbers reported in the paper were by evaluating on Rpi. For artifact evaluation, we are submitting the FVP. Though for reproducing the performance numbers, the system must be run on Rpi 3 B+. We are submitting a zip of our OPTEE setup because the OPTEE and FVP versions have been changed.

# Steps to Build and run
Please download the artifact zip from (https://drive.usercontent.google.com/download?id=1Kuoln4mEMCSg6197LQUBK7S_fhh_MJ3M&export=download&authuser=0)
The archive is around 5 GB, so we could not upload it to GitHub.

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
Once the FVP is booted up, Go to terminal 0 and login as with "root".
Run the following command in FVP terminal 0.

```bash
cd /usr/bin
sh run.sh [baseline|sulfur]
```

## Implementation details
We have developed a proof-of-concept implementation of our system as described in the paper. Most of the modifications were made to Linux and ARM Trusted Firmware (ARM-TF).

In Linux, we added support for system configuration protection, introduced Sulfur gates to save and restore process context, and simulated page fault overheads by invoking SMC calls in the page fault handler.

In ARM-TF, we implemented our Sulfur monitor handler, which writes to system registers and enforces policies. On the Raspberry Pi 3B+ platform, we were able to map the Normal World (NW) memory to the Secure World (SW) and update the NW memory from ARM-TF (via the Sulfur monitor).

For FVP, we applied changes in ARM-TF to enable mapping of NW memory to SW. While we verified that the memory mapping was successful, we were not able to access NW memory directly from ARM-TF.


We have implemented protection for system configuration as described below.
To achieve this, we replaced MSR instructions with SMC calls. There are a few corner cases where these calls could not be replaced. In the SMC handler, we defined policy logic prototypes for each system register.

As a prototype, we implemented a policy for SCTLR_EL1, which checks whether the WXN (Write XOR eXecute) bit is enabled. If the policy check passes, the write is permitted and carried out from the SMC handler. This ensures that the kernel cannot directly write to any system registers.

Some special registers require specific configurations to be enabled. In our implementation, we invoked an empty SMC call to EL3 to correctly account for the overhead, while the actual write is still performed from Linux. Similarly, if other special registers are required, we can provide the necessary parameters to Linux and ARM Trusted Firmware to enable them, and extend the policy accordingly.

Our system was developed on FVP and evaluated on the Raspberry Pi 3. To reproduce the performance numbers reported in the paper, the system must be run on a Raspberry Pi 3 B+.

## Accessing FVP Terminals Without GUI

When we run FVP using build.sh script, it generally spawns 4 FVP terminals. To access these terminals, a GUI is usually required. After booting up, you can run benchmark scripts in FVP terminal 0, where Linux boots.

If a GUI is not available, you can still access these terminals via telnet. For example, when running FVP on a local machine, we used the following command (here, port 5000 corresponds to FVP terminal 0):
```bash
telnet localhost 5000
```
After Linux boots, you can run this command in any terminal to access FVP terminal 0. If you are unable to access the Linux terminal on port 5000, try other ports such as 5001, 5002, or 5003.
