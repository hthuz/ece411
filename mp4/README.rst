.. .. raw:: html
..
..     <style> .red {color: red} .redst {color: red; text-decoration: line-through}</style>

.. role:: red
.. role:: redst

==========================
ECE 411: MP4 Documentation
==========================

-------------------------------------------------
A Pipelined Implementation of the RV32I Processor
-------------------------------------------------

    The software programs described in this document are confidential and proprietary products of
    Synopsys Corp. or its licensors. The terms and conditions
    governing the sale and licensing of Synopsys products are set forth in written
    agreements between Synopsys Corp. and its customers. No representation or other
    affirmation of fact contained in this publication shall be deemed to be a warranty or give rise
    to any liability of Synopsys Corp. whatsoever. Images of software programs in use
    are assumed to be copyright and may not be reproduced.

    This document is for informational and instructional purposes only. The ECE 411 teaching staff
    reserves the right to make changes in specifications and other information contained in this
    publication without prior notice, and the reader should, in all cases, consult the teaching
    staff to determine whether any changes have been made.

.. contents:: Table of Contents
.. section-numbering::

-----

.. _Appendix A: `Appendix A: RVFI`_
.. _Appendix B: `Appendix B: Spike`_

Introduction
============

This machine problem involves the design of a pipelined microprocessor. You are required to
implement the RV32I instruction set (with the exception of ``FENCE*``, ``ECALL``, ``EBREAK``, and
``CSRR`` instructions) using the pipelining techniques described in lectures. This handout is an
incomplete specification to get you started with your design, a portion of this machine problem is
left open ended for you to explore design options that interest you.

You will begin your design by creating a basic pipeline that can execute the RV32I instruction set.
Then, you will add support for hazard detection and data forwarding, as well as integrating a basic
cache system to your pipeline. After implementing a functional pipeline that can execute the RV32I
ISA, you will extend your design with advanced design options of your choosing. Finally, a
competition will be held to find which design can execute our benchmark program in the least amount
of simulation time and consuming the least amount of energy.

Getting Started
===============

Working as a Group
------------------

For this assignment, you must work in a group of three people. It will be your responsibility to
work on the assignment as a team. Every member should be knowledgeable about all aspects of your
design, so do not silo responsibilities and expect everything to work when you put the parts together.
Good teams will communicate often and discuss issues (either with the design/implementation or with teamwork)
that arise in a timely manner.

To aid collaboration, we provide a private Github repository [#]_ that you can use to share code
within your team and with your TA.

Part of working well as a team is being courteous to the rest of the team, even when you plan to drop
the class. We ask that you let TAs and the rest of your team know as soon as possible if you plan to
drop ECE 411, so we can reassign other people and minimize the number of issues later in the semester.

.. [#] Your repository may not be immediately available as team assignments need to be finalized,
       and then the repositories are all created manually. You will be able to find the repository
       in the same location as your MP repository when it is ready. The repositories will be setup in time for the second checkpoint.

Mentor TAs
----------

Each group will be assigned a mentor TA. You will have regular meetings with your mentor TA, so that
they know how your project is doing and any major hurdles you have encountered along the way. **You
must meet with your mentor TA at least once every week.** Scheduling these meetings is *your*
responsibility. Check with your mentor TA for their preferred scheduling method/availability.

In your first meeting with your mentor TA, you will review your paper design for your basic
pipeline and discuss your goals for the project. Before this meeting, you should have discussed in
detail with your team about what design options you plan to explore. Your mentor TA may advise
against certain options, but you are free to work on whatever you like. As the project progresses,
you may find that your goals and your design change. This is normal and you are free to take the
project in a direction that interests you. However, you must keep your mentor TA up to date about
any changes you have made or plan to make.

In order to get the most out of your relationship with your mentor TA, you should approach the
relationship as if your group has been hired into a company and given the MP4 design as a job
assignment. A senior engineer has been assigned to help you stay on schedule and not get overwhelmed
by tool problems or design problems. *Do not* think of the TA as an obstacle or hostile party. *Do
not* try to "protect" your design from the TA by not allowing him or her to see defects or problem
areas (your TA is there to help!). *Do not* miss appointments or engage in any other unprofessional
conduct. If you plan to make a late submission, your mentor TA should know as soon as possible, so
they can make sure you are still on track. Your mentor TA should be a consulting member of your
team, not an external bureaucrat.

Testing
-------

Throughout the MP, you will need to implement your own verification. This is extremely important as
untested components may lead to failing the final test code and competition benchmark.
Remember that in many of your components, such as the register bypassing unit, the order of the
instructions as well as what operands are used is crucial. You cannot just test that your processor
executes each of the instructions correctly in isolation. You should try to generate test code to
test as many corner cases as you can think of.

You need to have a working RVFI at the end of checkpoint 1. For help, See `Appendix A`_ of this document.

We've also provided some useful code to print out a commit log, which is in the same format as
Spike. See `Appendix B`_ for more detail.

Project Milestones
==================

MP4 is divided into several checkpoints to help you manage your progress. The dates for submissions
are provided in the class schedule. No late submissions are accepted for MP4. Missing deadlines in
this MP can cause schedule slips that may prevent you from having a successful final submission.

There will be five checkpoints to keep you on track for this MP. In addition, at each checkpoint,
you must meet, as a team, with your mentor TA and provide them with the following information in
writing:

- A brief report detailing progress made since the previous checkpoint (except for CP0, of course).
  This should include what functionality you implemented and tested as well as how each member of
  the group contributed.
- A roadmap for what you will be implementing for the following checkpoint. The roadmap should
  include a breakdown of who will be responsible for what and paper designs for all design options
  that you are planning to implement for the next checkpoint.

Refer to the `Progress Report and Roadmaps`_ section for more details on writing these reports.

Besides helping the TAs check your progress on the MP, the checkpoints are an opportunity for you to
get answers to any questions that may have come up during the design process. You should use this
time to get clarifications or advice from your mentor TA.

Note that the checkpoint requirements outline the minimum amount of work that should have been
completed since the start of the project. You should work ahead where possible to have more time to
complete advanced design options.


Checkpoint 0: Design Checkpoint
-------------------------------

The first submission for this project will be a design of your pipelined datapath. The design
must be detailed enough for the TAs to trace the execution of all RV32I instructions through
your datapath. The paper design must map out the entire pipeline, including components in all the
stages (e.g., registers, muxes, ALU, register file), stage registers, and control signals. In other
words, with the paper design in hand, you should be able to easily translate your design into RTL.
`Figure 1`_ shows an example of the overall structure of a design. You may use a similar
diagram, but you must provide details of the components in each stage.

We will not require your design to handle data forwarding at this point, but you may still want to
design for it to avoid having to change your design down the road. You also do not have to have
designs for your cache or arbiter ready yet, though thinking about these ahead of time
can save you considerable effort in Checkpoint 2. If completed, designs for advanced features such
as branch prediction can also be included.

A good way to start the pipeline design is to first determine the number of stages and the function
of each stage. Then you can go through the RV32I ISA (e.g. ADD, JAL, BEQ, SLT, etc.) to see what components
need to be added to each stage for a given instruction. You can use the textbook and lecture notes as
references.

.. _Figure 1:

.. figure:: doc/figures/diagram.png
   :align: center
   :width: 80%
   :alt: overview of pipeline datapath and cache hierarchy

   Figure 1: Overview of pipeline datapath and cache hierarchy. Note the location of the pipeline
   stages, stage registers, and arbiter. Your designs should be **much** more detailed than this.

Checkpoint 1: RV32I ISA and basic pipelining
--------------------------------------------

By checkpoint 1, you should have a basic pipeline that can handle all of the RV32I instructions (with the
exception of ``FENCE*``, ``ECALL``, ``EBREAK``, and ``CSRR`` instructions). You *do not*
need to handle any control hazards or data hazards. The test code will contain NOPs to allow the
processor to work without hazard detection. For this checkpoint you can use a dual-port "magic"
memory that always sets ``mem_resp`` high immediately, so that you do not have to handle cache misses
or memory stalls. You also need to have RVFI working at this checkpoint.

**Please note that your PC should start at 0x40000000 throughout this MP.**

At your TA meeting, you must provide your mentor TA with paper designs for data forwarding and
hazard detection, as well as a design for your arbiter to interface your instruction and data cache
with main memory.

Checkpoint 2: L1 caches + hazards and static branch prediction
--------------------------------------------------------------

By checkpoint 2, your pipeline should be able to do hazard detection and forwarding, including
static-not-taken branch prediction for all control hazards. Note that you should not stall or forward for
dependencies on register ``x0`` or when an instruction does not use one of the source registers (such as
``rs2`` for immediate instructions).

You must also have an arbiter implemented and integrated, such that both split caches (I-Cache and D-Cache)
connect to the arbiter, which interfaces with memory. Since main memory only has a single port, your arbiter
determines the priority on which cache request will be served first in the case when both caches miss and
need to access memory on the same cycle. From this CP, make sure your ``mp4/bin/generate_memory_file.sh`` has
``ADDRESSABILITY=8``

At your TA meeting, you must provide your mentor TA with proposals for advanced features. These may be as detailed
as you deem necessary -- anything from a written description to a hardware paper design. Your TA may have
feedback on implementation details or potential challenges, so the more detail you provide now, the more
helpful your TA can be.

Checkpoint 3: Advanced Design Options
-------------------------------------

Note: While the features in CP3 are important for your final design, correctness is infinitely more
important than performance. In general, you should not move on to CP3 until your code works
completely on all of the provided test codes. Coremark is required to execute correctly before you
start CP3 to receive any further credit. See the `Grading`_ section for further details on grading
and consult your mentor TA if you become concerned about your progress.

Checkpoint 3 is where your team can really differentiate your design. A list of advanced features
which you can choose to implement is provided in the `Advanced Design Options`_ section below, along
with their point values. This is **NOT an exhaustive list**; feel free to propose to your TA any feature
which you think may improve performance, who will add it to the list and assign it a point value.
The features in the provided list are designed to improve performance on most test codes based on
real-world designs.

In order to design, implement, and test them, you need to do background research and consult
your mentor TA. In order to decide on exact feature specifications and tune design parameters (e.g.,
branch history table size, and the size of victim cache), you need information about the performance of
your processor on different codes. This information is provided through **performance counters**.
You should at least have counters for hits and misses in each of your caches, for
mispredictions and total branches in the branch predictor, and for stalls in the pipeline (one for
each class of pipeline stages that get stalled together). Once you have added a few counters, adding
more will be easy, so you should add counters for any part of your design that you want to measure
and use this information to make the design better. The counters may exist as physical registers in
your design or as signal monitors in your testbench. **You will not recieve any advanced feature
points without corresponding performance counters.**

At your TA meeting, you should demo to your TA the advanced features you've implemented, and the
individual performance impact for each of the features. You should be able to demonstrate any
advanced features that you expect to get design points for, with your own test codes.

Checkpoint 4: Design Competition
--------------------------------

By checkpoint 4, you must have your final, optimized design ready for the competition.

While implementing advanced features is required to earn design points, you should be designing with
performance in mind. In order to motivate performance-centric thinking, part of your CP4 grade will
be determined by your design's best execution time on the competition test codes we provide.
Your score in the competition will be based on your relative performance to other teams in the
class. Details of the scoring method are provided in the `Grading`_ section.

- Ensure that your code works correctly. **Designs which cannot 100% correctly execute the
  competition code will receive 0 points for the performance part.**
- You *may* use a separate design for advanced feature grading and for the competition (i.e., you do
  not have to be timed with advanced features if they cause a performance hit on the benchmarks).

Checkpoint 4 marks the end of this MP. Your final submission should include all design,
verification, and testcode files used for your CP4 design (both advanced features and competition).

At your TA meeting, you will demo your final submission.

Presentation and Report
-----------------------

At the conclusion of the project, you will give a short presentation to the course staff (and fellow
students) about your design. In addition, you need to collect your checkpoint progress reports
and paper designs together as a final report that documents your accomplishments. **More information
about both the presentation and report will be released closer to the deadline.**


Grading
=======

MP4 will be graded out of 120 points, with uncapped extra credit. Out of the 120 base points, 60
points are allocated for regularly meeting with your TA, for submitting paper designs of various
parts of your design, for a final presentation given to the course staff, and for documenting your
design with a final report. For each checkpoint, you must meet with your mentor TA in order to
showcase the functionality of your design and your verification methods. Implementation points will
NOT be given otherwise.

A breakdown of points for MP4 is given in `Table 1`_. Points are organized into two categories
across six submissions. Note that the number of points you can attain depends on what advanced
design options you wish to pursue. Note that the ``+N`` points are extra credit.

.. _Table 1:

+-------------+-----------------------------------------+-----------------------------------------------------+
|             | Implementation [60]                     | Documentation [60]                                  |
+=============+=========================================+=====================================================+
| CP 0 [5]    |                                         | - TA Meeting [1]                                    |
|             |                                         | - Basic RV32I pipelined datapath design [4]         |
+-------------+-----------------------------------------+-----------------------------------------------------+
| CP 1 [22]   | - Basic RV32I pipelined datapath [8]    | - TA Meeting [1]                                    |
|             | - RVFI [4]                              | - Progress report [2]                               |
|             |                                         | - Roadmap [2]                                       |
|             |                                         | - Arbiter, hazard detection & forwarding design [5] |
+-------------+-----------------------------------------+-----------------------------------------------------+
| CP 2 [24+3] | - Integration of L1 caches [2]          | - TA Meeting [1]                                    |
|             | - Arbiter [3]                           | - Progress report [2]                               |
|             | - Hazard detection & forwarding [8]     | - Roadmap [2]                                       |
|             | - Static branch predictor [1]           | - Advanced features proposal and designs [5]        |
|             | - Coremark runs [+3]                    |                                                     |
+-------------+-----------------------------------------+-----------------------------------------------------+
| CP 3 [25+X] | - Advanced design options [20+X]        | - TA Meeting [1]                                    |
|             |                                         | - Progress report [2]                               |
|             |                                         | - Roadmap [2]                                       |
+-------------+-----------------------------------------+-----------------------------------------------------+
| CP 4 [44]   | - Design competition [24]               | - Presentation [10]                                 |
|             |                                         | - Report [20]                                       |
+-------------+-----------------------------------------+-----------------------------------------------------+
Table 1: MP4 point breakdown. Points for each item are enclosed in brackets. Point numbers after "+" signs are extra credits.

Progress Report and Roadmaps
----------------------------

You are responsible for submitting a progress report and a roadmap for each checkpoint. While these may
not seem like many points, they are instrumental in helping you and your mentor TA track your progress,
and can help address any issues you may have before they blow up.

Your progress report should mention, at minimum, the following:

- who worked on each part of the design

- the functionalities you implemented

- the testing strategy you used to verify these functionalities

- the timing and energy analysis of your design: fmax & energy report from Design Compiler

You should be both implementing and verifying the design as you progress through the assignment. It
will also be useful for you to include an updated datapath with each progress report, as your design
will inevitably change as you complete the assignment. Making sure your datapath is up-to-date will
help both you and your mentor TA track changes in your design and identify possible issues.
Additionally, a complete datapath will be required in your final report.

The roadmap should lay out the plan for the next checkpoint:

- who is going to implement and verify each feature or functionality you must complete

- what are those features or functionalities

It is also useful to think through specific issues you may run into, and have a plan for resolving the issues.

These are not intended to be very long. A single page (single-spaced) will be more than sufficient for both the
progress report and the roadmap. Be sure to check with your mentor TA, as they may have other details
to include on your progress report and roadmap.

Advanced Features
-----------------

Of the 60 implementation points, 28 will come from the implementation of the basic pipeline and
memory hierarchy. Up to 20 points will be given for the implementation of advanced design options.
Up to 12 points will come from your group's performance in the design contest. To receive any points
for the advanced design features, you must have numerical data which shows a change to your design's
performance as compared to not having implemented the feature. The best way to provide this data is
using performance counters. For each advanced design option, points will be awarded
based on the three criteria below:

- Design and implementation: Your group has a clear understanding of what is to be built and how to
  go about building it, and is able to produce a working implementation.

- Testing strategy: The design is thoroughly tested with test code and/or test benchmarks that you have
  written. Corner cases are considered and accounted for and you can prove that your design works as
  expected.

- Performance analysis: A summary of how the advanced design impacts the performance of your
  pipelined processor. Does it improve or degrade performance? How is the performance impact vary
  across different workloads? Why does the design improve or degrade performance?

A list of advanced design options along with their point values are provided in the
`Advanced Design Options`_ section.

Design Competition
------------------

TBD.

Group Evaluations
-----------------

At the end of the project, each group member will submit feedback on how well the group worked
together and how each member contributed to the project. The evaluation, along with feedback
provided at TA meetings throughout the semester, will be used to judge individual contribution to
the project. Up to 30 points may be deducted from a group member's score if it is evident that he or
she did not contribute to the project.

Although the group evaluation occurs at the end of the project, this should *not* be the first time
your mentor TA hears about problems that might be occurring. If there are major problems with
collaboration, the problems should be reflected in your TA meetings and progress reports. The
responses on the group evaluation should not come as a surprise to anyone.


Advanced Design Options
=======================

TBD.


Advice from Past Students
=========================

- On starting early:

  - "Start early. Have everything that you have implemented also in a diagram, updating while you
    go."
  - "START EARLY. take the design submission for next checkpoint during TA meetings seriously. it
    will save you a lot of time. Front-load your advanced design work or sufferrrrr"
  - "start early and ask your TA for help.""
  - "Finish 3 days before it's due. You will need those 3 days (at least) to debug, which should
    involve the creation and execution of your own tests!"
  - "Make the work you do in the early checkpoints bulletproof and it will make your life WAY easier
    in the later stages of MP3."
  - Don't let a passed checkpoint stop you from working ahead. The checkpoints aren't exactly a
    perfect balance of work.
  - (In an end-of-semester survey, most students responded that they spent 10-20 hours per week
    working on ECE 411 assignments.)

- Implementation tips:

  - "Don't trust the TA provided hazard test code, just because it works doesn't mean your code can
    handle all data and control hazards."
  - "Also, it was very good to test the cache interface with the MP 2 cache, and test the bigger
    cache you do (L2 cache, more ways, 8-way pseudo LRU) on the MP 2 datapath. This just makes it
    easier to stay out of each other's hair."
  - "Run timing analyses along the way so you're not trying to meet the 100 MHz requirement on the
    last night."
  - "Write your own test code for every case. Check for regressions."
  - "Don't pass the control bits down the pipeline separately, pass the *entire* control word down
    the pipeline. Also, pass the opcode and PC down. These are essential when debugging."
  - "Check your sensitivity lists!!"
  - "Hook up the debug utilities, shadow memory and RVFI monitor, early. It helps so much later."
  - "RISC-V MONITOR please start using it at CHECKPOINT 1!"  (TA note: we suggest using RVFI
    Monitor beginning with CP3.)
  - "Performance counters might seem unnecessary at first, but they totally saved our competition
    score. Make a lot of them, and use them!!"

- Possible difficulties:

  - "Implement forwarding from the start, half of our bugs were in this. Take the paper design
    seriously, we eliminated a lot of bugs before we started."
  - "Integration is by far the most difficult part of this MP. Just because components work on their
    own does not mean they will work together.''
  - "The hard part about mp3 is 1) integrating components of your design together and 2) edge cases.
    Really try to think of all edge cases/bugs before you starting coding. Also, be patient when
    debugging."
  - "You might think it makes sense to gate the clock in certain circumstances. You are almost certainly
    wrong. Don't gate the clock."
  - "The TAs might seem nice, but they don't give you very good testcode. Make sure to write your own."

- On teamwork:

  - "Try to split up the work into areas you like -- cache vs datapath, etc. You will be in the lab
    a lot, so you might as well be doing a part of the project you enjoy more than other parts"
  - "Don't get overwhelmed, it is a lot of work but not as much as it seems actually. As long as you
    start at least a paper design ASAP, you should finish each checkpoint with no problems."
  - "Come up with a naming convention and *stick to it*. Don't just name signals ``opcode1``,
    ``opcode2``, etc. For example, prepend every signal for a specific stage with a tag to specify
    where that signal originates from (``EX_Opcode``, ``MEM\_Opcode``)."
  - "Label all your components and signals as specific as possible, your team will thank you and you
    will thank yourself when you move into the debugging stages!"
  - "Learn how to use Github well! It is very difficult to get through MP3 without this knowledge."
  - "If you put in the work, you'll get results. All the tools you need for debugging are at your
    disposal, nothing is impossible to figure out."
  - "Split up the work and plan out which parts everyone will work on each checkpoint. You can always
    help each other out, but make sure you know who is responsible for each part."
  - "You need to be able to read each other's code. Agree on a style head of time, and don't rely on
    others all the time. Not being able to read code makes debugging unnecessarily difficult."


Appendix A: RVFI
================

It is mandatory for your RVFI to be working during your CP1 demo. RVFI is a handy tool that will
snoop the commits of your processor, and check with the spec to see if your processor has any
errors. It essentially runs another RISC-V core parallel to yours and crosschecks that your commits
are correct. The RVFI file is at ``mp4/hvl/rvfimon.sv``. You need to instantiate it in your top
testbench (we've provided some hints in your ``mp4/hvl/source_tb.sv``), and give it the correct
signals. You might want to search "Verilog hierarchical reference" to see how to access module
internal signals from the top/testbench module. Please only use hierarchical reference in
verification, never use it in design. To get started, you could look at this:
https://github.com/SymbioticEDA/riscv-formal/blob/master/docs/rvfi.md

We will provide the signals RVFI needs in your ``mp4.sv``. You will hook these up to get RVFI
working. Here are details about some of the signals:

- Order is a serial number assigned to each instruction. It should start at 0, it should be unique, and it should
  be serial. Each instruction must only be valid for one cycle.
- There is no dedicated read and write enable signal in RVFI, use mask=4'h0 to indicate not reading.
  You should also specify the read mask according to the location which you are reading, even though
  our memory does not take a read mask.

All of the signals going to RVFI should be from your write back stage / ROB, corresponding to the current instruction
being committed. You should pass all this information down the pipeline. You do not have to worry about wasting resources
on data which the write back stage does not need, since the synthesis tool will optimize them out.

If you see RVFI giving error messages during simulation: congratulations, you've successfully set up your RVFI.
If not, try to intentionally break your CPU and see if it shows you the correct error message.

Some common RVFI errors:

- ROB error:
  This means that your order/valid has some issue. Check if your order starts at 0, or if you have
  some ID that was skipped or committed more than once.
- Shadow PC error:
  Likely your processor went on a wrong path, usually by an erroneous jump/branch.
- RD error:
  Likely the ALU calculation is wrong.
- Shadow RS1/RS2 error:
  Likely forwarding issue.

Appendix B: Spike
=================

Spike is the golden software model for RISC-V. You can give it a RISC-V ELF file and it will run it
for you. You can also interactively step through instructions, look at all architectural states and
also memory in it. However it is likely that you do not need these features for this MP. You would
likely only want it to give you the golden trace for your program.

The code provided in ``mp4/hvl/monitor.sv`` will print out a log in the exact same format as in
``sim/spike.log``. You can use your favorite diff tool to compare the two. Note that the log
printing logic uses the same signals as RVFI does.

When you are trying to run Spike on your own testcode, make sure to include all the lines about
``tohost`` in the example testcode, and the 4 lines that write 1 into ``tohost`` right before
halting. Spike only terminates when you ``sw`` into a special 'variable' in your assembly code, so
failing to include these instructions will lead to Spike getting stuck in the infinite loop. Spike
uses ``x5``, ``x10``, and ``x11`` for some internal purposes before it actually jumps to run the ELF
you supplied. Keep this in mind when you are writing your own test code.
