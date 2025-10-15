# BSC Installation Methods


## Installation Method 1 -- The easiest -- use prebuilt image (for x86_64 -- 64bit Intel/AMD; also for Mac with M1/M2/M3)

There are ready-to-go installations for several operating systems on x86_64 and ARM. You can simply download, extract, and use.

Note for Windows users: If you use Windows you're probably on an x86_64 architecture. We recommend using [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install). It is preferred to use the WSL-2 setup if applicable. The default distribution is Ubuntu-20.04, which is compatible with this method. Debian 12 will also work.

Note for Linux/other users: Enter `arch` to see what architecture you're on. It should say `x86_64` unless you're on a Raspberry Pi or something funny.

### Step 1: Download Prebuilt Image
- Go to https://github.com/B-Lang-org/bsc/releases/tag/2023.07 (for ARM64/M1/2/etc Mac https://drive.google.com/file/d/1YC-oLBo9XCXHUuYJSUBrOGV5Topj59H-/view?usp=sharing)
##### 1.1 For X86_64 based machines
- Download bsc-2023.07-<OS>.tar.gz
Where <OS> could be "debian-10.13", "debian-11.7", "debian-12.1", "macos-11", "macos-12", "macos-13", "ubuntu-18.04", "ubuntu-20.04", "ubuntu-22.04", depending on what operating system you're using.

If you don't know what flavor of Linux you're on, but know that you're probably on some Linux-type thing, try the `lsb_release` command and see if it matches one of the available installations.

If you're unfamiliar with downloading through the command line, you can use `wget` with the file link, e.g., `wget https://github.com/B-Lang-org/bsc/releases/download/2023.07/bsc-2023.07-ubuntu-20.04.tar.gz` for Ubuntu 20.04 or `wget https://github.com/B-Lang-org/bsc/releases/download/2023.07/bsc-2023.07-debian-12.1.tar.gz` for Debian 12.1. A `tar.gz` is a tar ball, or a kind of compressed file, like a `.zip`, which we extract in the next step.

As for Intel Macs, the link would be something like `wget bsc-2023.07-macos-13.tar.gz`

##### 1.2 For ARM64 based machine, like Mac with M1/M2/M3
Please download the prebuilt binary from https://drive.google.com/file/d/1YC-oLBo9XCXHUuYJSUBrOGV5Topj59H-/view?usp=sharing

### Step 2: Decompress the tar ball

Install the git before downloading the repo
```bash
apt install git
```

This step gets the good stuff out of the compressed file, extracting the files into a folder the same name as your tar ball.
```
tar -xvf bsc-2023.07-<OS>.tar.gz
tar -vxf bsc_compiled_mac_arm64.tar (ARM Mac)
```

where the flags after `-`: `x` means e**x**tract, `v` means **v**erbose, and `f` means the next argument is the **f**ile we're trying to work with.

Once you extract the files, you can delete the tar ball.

```
rm bsc-2023.07-<OS>.tar.gz
```

And you can rename the folder if you want, to something like just `bsc`.

e.g.,

`mv bsc-2023.07-<OS> bsc` (already renamed in the arm mac version)

A good place to put your installation for WSL/Linux is `/usr/local/`. To get there, do `cd /usr/local`. 
To install it, you can move the bsc folder to the place of your choice. We recommend the default. e.g. `sudo mv bsc /usr/local`.

### Step 3: Setup PATH for running bsc
This step is important so that you can call `bsc` from anywhere in your file system, not just the one where the installation is.

You just need to add the path of `bsc` to your `PATH` environment variable. `PATH` holds the paths of your command line programs. When you call a program, e.g., `bsc` or `cd` or something, your terminal walks through the `PATH` variable looking for the program.

If you're using WSL/Linux, put this line in your `~/.bashrc` file, e.g., with `nano ~/.bashrc` (add to the bottom). Some other systems use a different file, e.g., `~/.profile` (e.g. Macs probably). Let us know if you have any trouble with it.

e.g.,
```
export PATH=/usr/local/bsc/bin:$PATH

export PATH=/usr/local/bsc/inst/bin:$PATH  (for ARM Macs)

# or if you had not renamed it...

export PATH=/usr/local/bsc-2023.07-<OS>/bin:$PATH
```


After you add that to `~/.bashrc`, run `source ~/.bashrc` to update your path.

Debian/Ubuntu users: You may also need `sudo apt-get install libtcl8.6 make build-essential` if they are not installed to compile labs. You may need `sudo apt-get update` before. 

You can now run `bsc` on your computer. This is the bluespec compiler.

For modern Macs... you might get a secutity issue. Follow https://support.apple.com/en-us/HT202491 for each error running `bsc` gives (should be 3 times roughly). I.e. run `bsc`, if there is an error press open, then when it fails go to Privacy & Security in settings and press open anyway at the bottom for the errored app. Repeat a few times until no errors are given and the usage is displayed instead.

**NOTE:** When trying to compile bsc files using the terminal within VS Code on arm Mac you may get an error similar to `linker exit code: 1`. This error has
to do directly with running the intel x86 version of VS Code on an arm Mac. Running the compile commands directly in the Mac terminal or installing the arm version of VS Code will fix this.

## Installation Method 2 -- Second easy one -- To run BSC in the docker

We provide the following docker file. Both links lead to the same file.

Dropbox: https://www.dropbox.com/s/byfn7nczfqoy82r/bsc_docker.tar?dl=0

(Mirror) Google Drive: https://drive.google.com/file/d/1DwgVHowVWBOl5fUQCiYtHrQtu9PbODas/view?usp=sharing

For ARM M1/M2/M3 Macs: https://www.dropbox.com/scl/fi/abiks4nk61hxmp6yoq06c/bsc_arm_ubuntu2204.tar?rlkey=onqkpazk300j69zvavy6nhdko&dl=0

### Step 1: Docker installation
Follow the instructions guideline [here](https://docs.docker.com/engine/install/) to install docker on Window/Linux/Mac

### Step 2: Download the docker from the provided shared driver

Run the following command to launch the docker
```
sudo docker load -i <docker_tarball_name>.tar
sudo docker run -it <docker_tarball_name>:latest
```

As for X86_64: <docker_tarball_name> = bsc_docker 
As for Apple Silicon <docker_tarball_name> = bsc_arm_ubuntu2204
This is the newest method, so if anything is missing then post to Piazza or come to Jianming's OH.

## Installation Method 3 -- Built from source -- MAC (ARM-based M1/M2/M3) or Linux/WSL

Which step 1 you use depends on your OS. This can be a little tricky, so feel free to do this in office hours.

For linux or WSL users, please install the following dependency
```
apt-get install tcl-dev build-essential pkg-config autoconf gperf flex bison iverilog ghc-prof libghc-regex-compat-prof libghc-syb-prof libghc-old-time-prof libghc-split-prof ghc libghc-regex-compat-dev libghc-syb-dev libghc-old-time-dev libghc-split-dev
```

### Step 1a (MacOS only): Install Homebrew
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install autoconf gmp pkgconfig

```

### Step 1b (Linux/WSL only): Install build tools
```
sudo apt install build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5
```

### Step 2: Install haskell (if you don't already have it)
Why do you need Haskell? A large chunk of BSC is written in Haskell, and we're compiling it from its Haskell source.

```
# install git
brew install git

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
# install haskell libraries (If the command cabal is not recognized, quit and re-open terminal)
cabal update
cabal v1-install regex-compat syb old-time split

# Clone recursively the Bluespec repo
git clone --recursive https://github.com/B-Lang-org/bsc

# Build the bluespec compiler
cd bsc
make release

# You might get error when it comes to compilation of the documentation or other secondary build targets. This is not an issue for the class. You may also have to install additional libaries as required by error output.
# To make sure the build succeeded call:
./inst/bin/bsc

``` 

### Step 3: Updating PATH variable
To avoid having to type the whole path to bsc all the time, add the `inst/bin` directory to your `PATH` variable. For example in ~/.bashrc you can append:
```export PATH=<pathWhereYouCloned-bsc>/bsc/inst/bin/:$PATH```

For a slightly more detailed explanation, see Step 3 of Method 1.

---

To test your installation, go back to the [README](/README.md) and try the exercise associated with `getting_started`.

Enjoy! XD

---

## Installation method 4 -- Athena (if all else fails)

This isn't strictly installed, but you just need a ssh client (e.g. Putty on Windows, or built in on most Linux and Macs machines). This is provided in the 6.004 locker.

```
ssh <kerb>@athena.dialup.mit.edu
add 6.004
source /mit/6.004/setup.sh
bsc # this should show bluespec compiler help
git clone <your repo>
cd <repo>
make # or whatever specific build instructions are needed
```
You can add lines 2 and 3 to your `.bashrc` if you don't want to have to keep reloading it on login.

## Appendix: Other Libraries
Bluespec doesn't yet have a library system system for libraries outside of the standard library. Instead, they are held in the [bsc-contrib repository](https://github.com/B-Lang-org/bsc-contrib). I don't expect you'll need this unless you're building for FPGA.

