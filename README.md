# Prototype for Sulfur OS : Non-Bare-Metal User-Space Control-Flow Attestation
This repository contains the prototype implementaion for our paper Non-Bare-Metal User-Space Control-Flow Attestation. 

# Development & Testing Environment
We build our proof-of-concept implementation on top of OPTEE and FVP. The numbers reported in the paper were by evaluating on Rpi. For artifact evaluation, we are submitting the FVP. Though for reproducing the performance numbers, the system must be run on Rpi 3 B+. We are submitting a zip of our OPTEE setup because the OPTEE and FVP versions have been changed.

# Steps to Build and run
Please download the artifact zip from https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/nikitayadav_iisc_ac_in/EfYoWpJK_5FFq-EZTmKDeXQBlMiYWCb6L9J1c1Geg07NlQ?e=VfVTQ9 
Since it is quite big, we could not push it on github.

1. Run install.sh script to install OPTEE pre-requisites.

```bash
sudo ./install.sh
```

2. Run build.sh to build OPTEE and FVP. Invoke this script with either "baseline" or "sulfur" to build baseline and sulfur respectively.

```bash
sudo ./build.sh baseline/sulfur 
```

3. The benchmarks can be run and tested via the FVP Xterminals. 
    3.1 Once the FVP is booted up, Go to terminal 0 and login as with "root"
    3.3 Run the following command in FVP terminal 0.

```bash
sh /usr/bin/run.sh [baseline|sulfur]
```

## Implementation details
We replaced MSR instructions with SMC calls. There are some corner cases where we were unable to replace those calls. In the SMC handler, we have defined policy logic prototypes for each register.

We implemented a prototype policy for SCTLR_EL1, which checks if the WXN (Write XOR eXecute) bit is enabled or not. If the policy check passes, then we allow the write, and the write is performed from the SMC handler. This ensures that the kernel is unable to directly write to any system registers.

There are some special registers that require specific configurations to be enabled. In our implementation, we invoked an empty SMC call to EL3 to account for the correct overhead, and we are writing to that register from Linux. We also implemented a prototype for One catgory of special register Pointer Authentication (PAUTH) registers. Similarly, if other special registers are required, we can provide the appropriate parameters to Linux and to ARM Trusted Firmware to enable them, and we can also add them into the policy.

Secondly, we wrote a macro for the set_pte kernel function. In this function, we have the physical address of the page table entry and the value that we need to write. We pass these to the SMC handler.By applying appropriate mapping (either dynamic mapping or identity mapping of the entire non-secure memory), we can also perform the write.

Currently In SMC Handler of set_pte, we only log the physical address of the non-secure world page table entry along with the value that is being written. We then perform policy checks in the SMC handler and either reject the write or allow it based on the implemented policy. One prototype policy checks whether WXN is enabled or not. 
