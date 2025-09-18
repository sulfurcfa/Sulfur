# Prototype for Sulfur OS : Non-Bare-Metal User-Space Control-Flow Attestation
This repository contains the prototype implementaion for our paper Non-Bare-Metal User-Space Control-Flow Attestation. 

# Development & Testing Environment
We built our proof-of-concept implementation on top of OP-TEE and the ARM FVP platform. The performance numbers reported in the paper were obtained by evaluating on a Raspberry Pi 3 B+. For artifact evaluation, we provide the FVP-based setup. To reproduce the exact performance results, however, the system must be run on Raspberry Pi 3 B+. We are submitting a packaged OP-TEE setup as a zip file, since the OP-TEE and FVP versions have changed since our experiments.

# Steps to Build and run
Please download the artifact zip from https://drive.usercontent.google.com/download?id=1Kuoln4mEMCSg6197LQUBK7S_fhh_MJ3M&export=download&authuser=0.

The archive is approximately 5 GB in size, so we were unable to upload it to GitHub.

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
