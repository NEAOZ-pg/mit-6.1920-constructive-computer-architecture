# lab0: Setup and Warmup

Welcome to 6.192! This lab is mainly meant to help you setup your local Bluespec Compiler installation so you can work on future assignments, like upcoming Lab 1a later this week and the rest of Lab 1 next week. The only thing due for this assignment is the feedback form, which also serves as the welcome-to-class survey.

In 6.191, you would have used an Athena locker, but here we ask that you install locally. We've tried to keep it simple, but please ask on Piazza or come to office hours if you have any trouble.

## Downloading this repository

For linux/WSL users, make sure you have git installed -- i.e. `sudo apt-get install git`. It *should* be preinstalled on Mac OS X if I remember correctly.

In your favourite directory, run `git clone https://github.com/6192-sp24/lab0.git`. Now you can do `cd lab0` to access the lab.

For WSL users -- you should be able to see the Linux home directory files in Windows File Explorer under the Linux tab on the left pane.

Make sure to follow the instructions in Installation.md before continuing.


## Important Resources
Do you have access to these?
- [Canvas](https://canvas.mit.edu/courses/25337)
- [Piazza](https://piazza.com/mit/spring2024/6192)
- [Course Google Calendar](https://calendar.google.com/calendar/u/0?cid=Y19lNDhmYzhmM2Q3MjIwYzZhODdjYTMxMjc4YTk1M2FjNjZiNzA5ZWVkNTMyZGExNGExZWRjMDUzNjc5NTA3N2I4QGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20) with times of lectures, recitations, and office hours.

## Installing Bluespec Compiler

Bluespec SystemVerilog (BSV), or Bluespec, is an open-source high-level hardware description language (HDL). You may be familiar with [Minispec](https://github.com/minispec-hdl/minispec) from 6.191 with its `.ms` files, which uses Bluespec as its backend.

Bluespec is a compiled language, which means you need a compiler to turn your Bluespec `.bsv` files into files that you can actually run. The main tool we will be using is the [Bluespec Compiler](https://github.com/B-Lang-org/bsc) (BSC).

We have prepared [instructions](/Installation.md) for the most common operating systems (Linux, macOS, Windows).
- If you use an `x86_64`-based processor and a semi-common operating system, it should be a straightforward process of downloading and extracting a prebuilt binary and adding it to your `PATH` environment variable.
- If you use a less common operating system but still use an `x86_64`-based processor, we have prepared a Docker image that should work.

If these don't work, please come see us in office hours.

You can also see the [official Bluespec language installation guidance](https://github.com/B-Lang-org/bsc/blob/main/INSTALL.md)

## Checking that it works
As you may recall from Lec 01, the BSC converts your human-readable BSV into two main representations. Let's try it out. Go into the `getting_started` directory.

`cd getting_started`

Right now, there should be only two files in the directory. You can ignore the `Makefile` for now; let's focus on the `start.bsv`. It's a simple Bluespec module that is just meant to let you play with `bsc`. Take a brief look into it and try to understand what it does.

Now let's build it into something the machine can understand. Run and look at `bsc --help` for some of the options. It has a lot more information than we need to focus on right now, but scroll up to the `Usage` section.

You'll see there are two large groups of options to use with `bsc`: `-verilog` and `-sim`. These represent the two main targets we can compile to: Verilog files, which we can use to generate hardware or simulate using industry-standard Verilog tools like Verilator, or Bluesim files, which we can (more quickly) simulate to better debug our hardware. You may recall from lecture that these are designed to be cycle-accurate. This property is important because in hardware design, we want to use the simulation to debug the hardware (i.e., Verilog).

For most of this class, we'll be relying on the Bluesim files, but the Verilog target is what's necessary to deploy Bluespec onto hardware like FPGAs or ASICs. Right now, we're using `bsc -sim`.

Our first command below generates (`-g`) objects corresponding to the `start` module in the `start.bsv` file. `bsc` makes the `.ba` object file as the output of this command, though we also have the `.bo` file as an intermediate output.

`bsc -sim -g start start.bsv`

Next, we would like to link our `.ba` object files into a top level module (usually a module implementing the `Empty` interface) that we then simulate. This is a more interesting command for large projects, but right now we only have one object, the `start.ba` object file that we just generated. And we produce an executable (`-o`) named `start`.

`bsc -sim -e start -o start`

Notice that this command generates a rather large number of files. Don't worry about them. The one we're interested in is `start`. Try running it.

`./start`

You should have gotten the following output:

```
Hello world!
Goodbye world!
```

Next, let's look at a cleaner way of doing what we just did.

## Cleaning things up

Generally, we will provide a `Makefile` that calls the `bsc` commands for you so that you don't need to feed in all the flags and other options. Otherwise, it'd be a pretty big pain to remember and type up everything just to run your Bluespec. The hard part should be reasoning about your hardware designs, not running the simulation.

Take a look inside the `Makefile`. We have provided two targets: `clean` and `start`. You can read the commands that they call, indented below each target.

Let's try to clean up the files we made. Generally, Makefiles will have `make clean` to remove the files that the other targets produce.

`make clean`

Now, let's try the other target with `make start`. Generally the target name is the file that we're trying to produce, which here is the `start` binary.

`make start`

Notice that it's much cleaner now. We still generate a `start` and `start.so` file in our directory (they are connected; `start` actually calls Bluesim to consume `start.so`), but we have generated our build files and simulation files in `build` and `sim` directories respectively. Keeping a clean directory makes it easier for you to navigate your important files.

Try `./start` again to see that you get what you got before.

Even though we generally provide you with a Makefile, it's still worth knowing what happens under the hood in case you need to write your own modules or test benches outside of the skeleton code we provide.

If you'd like to read more into how the toolchain works, check out Chapter 2 of the BSC User Guide.

## Other Helpful Resources

### Tutorials
Some people have written Bluespec tutorials:

- [Kathy Camenzind's Bluespec Intro Guide](https://github.com/kcamenzind/BluespecIntroGuide) was originally written in 2018 for when 6.004 (now 6.191) was transitioning to Bluespec. It contains a pretty comprehensive overview of Bluespec features that you might like to know.
- [Rishiyur Nikhil's and Kathy Czeck's BSV by Example](http://csg.csail.mit.edu/6.S078/6_S078_2012_www/resources/bsv_by_example.pdf) was written much longer ago by one of the cofounders of Bluespec, and serves as good reading material for understanding Bluespec.

### Documentation
If you need help with Bluespec or would like to read more about it, please check out these [documents](https://github.com/B-Lang-org/bsc#Documentation) maintained by the Bluespec Language organization. You may not need them yet, but you should remember that they're available.

- [BSV Language Reference Guide](https://github.com/B-Lang-org/bsc/releases/latest/download/BSV_lang_ref_guide.pdf) specifies the Bluespec language and is a good go-to for information about language features and syntax.
- [BSC Libraries Reference Guide](https://github.com/B-Lang-org/bsc/releases/latest/download/bsc_libraries_ref_guide.pdf) covers the standard libraries, including such things like `FIFO`, `BRAM`, and `Vector`.
- [BSC User Guide](https://github.com/B-Lang-org/bsc/releases/latest/download/bsc_user_guide.pdf) covers how the toolchain works, like arguments to `bsc` and what happens under the hood.

### Syntax Highlighting
If you use VS Code, one of our TAs maintains a [Bluespec syntax highlighting extension](https://marketplace.visualstudio.com/items?itemName=MartinChan.bluespec) available on the VS Code Marketplace.

If you use Vim or Emacs, we also have a couple syntax highlighting files from a decade ago that we borrowed from Bluespec Inc, probably from a decade before then. Check out the `emacs` and `vim` directories in the [the old class site](http://csg.csail.mit.edu/6.175/resources/). At the time I'm writing this I'm not sure how to download files from there, but if you're using Emacs or Vim then you can probably figure it out. If you'd like to be helpful, be the first to upload it to Piazza for your peers, and we'll update this to point to the files.

We don't yet have more modern smart IDE features yet for Bluespec like you may be used to from popular software languages, but ask Martin about it in recitation if you're interested 😏

### Staff Help

And of course you're always welcome to post (or answer!) questions on Piazza or discuss with staff in office hours. If none of the times work for you, let us know and we can probably move some around.

## Feedback Survey
This is the second time we've offered the class since 6.191 started using Minispec for their labs. This class was offered last year, but before that was in 2017.

We're trying to keep the content both accessible (so not too hard) and engaging (so not too easy) and we'd like your help to achieve that balance. After every assignment we will have a feedback form. Some changes we'll be able to implement this semester, but others will help us improve the class for later semesters. These surveys will also be opportunities for you to give feedback on lectures, recitations, etc.

This week, I'd like you to spend some time filling out [this survey](https://docs.google.com/forms/d/e/1FAIpQLSdPQ_XcBIVkmnK4cQa86ulicTaHfWIx9burw7mLKrnEC2l0vg/viewform?usp=sf_link). We really appreciate your help!

---
`version: 0`
