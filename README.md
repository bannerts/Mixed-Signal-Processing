
College Thesis: Mixed Signal Processing: Hardware Electrodynamics, Integration Scaling, and Concept Simulation

# Mixed Signal Processing: Hardware Electrodynamics, Integration Scaling, and Concept Simulation

### Scott Bannert, MSME
### The University of Texas at Austin, 2007
### Supervisors: Benito Fernandez & Michael Bryant


# ABSTRACT
Basic hardware components for Mixed Signal Processing–analog computing inside a digital framework–are developed. The Hybrid Integrator integrates analog signals similar to analog computers avoiding op-amp saturation. These analog signals are scaled and combined with digital signals inside a Hybrid Format, forming a Hybrid Signal. The Hybrid Integrator Cell combines multiple Hybrid Signals through the use of multiple R-2R ladders and other supporting components for computing. Multiple Hybrid Integrator Cells combined in parrallel form a Hybrid Integrator Cell Array, syncronizing the integration of multiple mixed signals. An integration scaling process is developed, constraining Hybrid Signals during integration computing; this is discussed for both linear and nonlinear systems of first order ordinary differential equations (ODE’s). Lastly, program code is developed to simulate Mixed Signal Processing, demonstrating the expected results of Mixed Signal Processing for solving various simple ODE’s.



# TABLE OF CONTENTS ###


## Part I: Introduction

### Chapter 1 Overview 1
#### 1.1 Digital Computing . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1

#### 1.2 Analog Computing . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
#### 1.3 Mixed Signal Processing . . . . . . . . . . . . . . . . . . . . . . . . . 2
##### 1.3.1 Hybrid Format . . . . . . . . . . . . . . . . . . . . . . . . . . 3
##### 1.3.2 MSP Hardware . . . . . . . . . . . . . . . . . . . . . . . . . . 3
##### 1.3.3 Integration Scaling . . . . . . . . . . . . . . . . . . . . . . . . 3
##### 1.3.4 Simuating MSP . . . . . . . . . . . . . . . . . . . . . . . . . . 3

### Chapter 2 Notation 4

### Chapter 3 Signal Formats 11
#### 3.1 Signed Two’s Compliment Format . . . . . . . . . . . . . . . . . . . 11
#### 3.2 Floating Point Representation . . . . . . . . . . . . . . . . . . . . . . 13
##### 3.2.1 Floating Point Ranges . . . . . . . . . . . . . . . . . . . . . . 13
##### 3.2.2 Digital Signal Evaluation . . . . . . . . . . . . . . . . . . . . 14
##### 3.2.3 IEEE 754 Format . . . . . . . . . . . . . . . . . . . . . . . . . 15
#### 3.3 Other Digital Registers . . . . . . . . . . . . . . . . . . . . . . . . . . 16
#### 3.4 Mixed Signal Representation . . . . . . . . . . . . . . . . . . . . . . 17
##### 3.4.1 Linear Mixed Signal Format . . . . . . . . . . . . . . . . . . . 18
##### 3.4.2 Floating Point Hybrid Format . . . . . . . . . . . . . . . . . 19

### Chapter 4 Basic Modeling 23
#### 4.1 Modeling Op-Amp Behavior . . . . . . . . . . . . . . . . . . . . . . . 23
#### 4.2 Capacitor Circuit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
#### 4.3 R2R Ladder Modeling . . . . . . . . . . . . . . . . . . . . . . . . . . 25
##### 4.3.1 Ideal Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25
##### 4.3.2 Detailed Model . . . . . . . . . . . . . . . . . . . . . . . . . . 26


## PART II: Hardware Components 28

### Chapter 5 Hybrid Integrator: HxI 29
#### 5.1 Hybrid Integrator Layout . . . . . . . . . . . . . . . . . . . . . . . . 29
#### 5.2 Op-amp Integrator Circuit . . . . . . . . . . . . . . . . . . . . . . . . 29
#### 5.3 Comparator Circuit . . . . . . . . . . . . . . . . . . . . . . . . . . . 30
#### 5.4 Reset Circuit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 31
#### 5.5 Reset Timing Circuit . . . . . . . . . . . . . . . . . . . . . . . . . . . 33
#### 5.6 Output Buffer Circuit . . . . . . . . . . . . . . . . . . . . . . . . . . 35

### Chapter 6 Hybrid Integrator Cell 36
#### 6.1 Polygratror Semantics . . . . . . . . . . . . . . . . . . . . . . . . . . 36
#### 6.2 Component Layout . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36
##### 6.2.1 Hybrid Integrator Cell Addressing . . . . . . . . . . . . . . . 38
#### 6.3 Control Unit . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 38
#### 6.4 DAC . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 38
#### 6.5 R2R . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 39

### Chapter 7 Hybrid Integrator Cell Array: HxA 40
#### 7.1 Component Layout . . . . . . . . . . . . . . . . . . . . . . . . . . . . 40
#### 7.2 HxA Modeling . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 40
##### 7.2.1 Op-Amp Integrators . . . . . . . . . . . . . . . . . . . . . . . 40
##### 7.2.2 Integrator Currents . . . . . . . . . . . . . . . . . . . . . . . . 41
##### 7.2.3 DAC/R2R Current . . . . . . . . . . . . . . . . . . . . . . . . 41
##### 7.2.4 Inverting Terminal Voltage . . . . . . . . . . . . . . . . . . . 42
#### 7.3 Solving the Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . 42


## PART III: Processing Mixed Signals 45

### Chapter 8 ODE Representation 46
#### 8.1 Time Invariant ODE’s . . . . . . . . . . . . . . . . . . . . . . . . . . 46
#### 8.2 Avoiding Time Dependencies . . . . . . . . . . . . . . . . . . . . . . 47
##### 8.2.1 ODE Layout . . . . . . . . . . . . . . . . . . . . . . . . . . . 47
##### 8.2.2 Time-State Substitution . . . . . . . . . . . . . . . . . . . . . 47
##### 8.2.3 Modified ODE Vector Function . . . . . . . . . . . . . . . . . 48
#### 8.3 Modified Denormalization for ODE’s . . . . . . . . . . . . . . . . . . 48
##### 8.3.1 ODE Layout . . . . . . . . . . . . . . . . . . . . . . . . . . . 49
##### 8.3.2 State Variable Scaling . . . . . . . . . . . . . . . . . . . . . . 49
##### 8.3.3 Substituted Form . . . . . . . . . . . . . . . . . . . . . . . . . 50

### Chapter 9 Integration Scaling Development 51
#### 9.1 Problem Statement . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
#### 9.2 Function Approximation . . . . . . . . . . . . . . . . . . . . . . . . . 52
##### 9.2.1 Taylor Series . . . . . . . . . . . . . . . . . . . . . . . . . . . 52
##### 9.2.2 Integral Approximation . . . . . . . . . . . . . . . . . . . . . 53
#### 9.3 Symbolic Representation . . . . . . . . . . . . . . . . . . . . . . . . . 53
##### 9.3.1 Mixed Signals . . . . . . . . . . . . . . . . . . . . . . . . . . . 53
##### 9.3.2 Time Scaling . . . . . . . . . . . . . . . . . . . . . . . . . . . 54
##### 9.3.3 Symbolic Form of Integral . . . . . . . . . . . . . . . . . . . . 54
#### 9.4 Ideal Hardware Dynamics . . . . . . . . . . . . . . . . . . . . . . . . 54
#### 9.5 Analog Bit Reset Updating . . . . . . . . . . . . . . . . . . . . . . . 55
##### 9.5.1 Positive Resets . . . . . . . . . . . . . . . . . . . . . . . . . . 56
##### 9.5.2 Negative Resets . . . . . . . . . . . . . . . . . . . . . . . . . . 56
#### 9.6 Function Approximation Constraint . . . . . . . . . . . . . . . . . . 56

### Chapter 10 Integration Scaling Control 57
#### 10.1 Control Variables . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 57
#### 10.2 Hardware Constraints . . . . . . . . . . . . . . . . . . . . . . . . . . 58
#### 10.3 Digital Processing Constraints . . . . . . . . . . . . . . . . . . . . . . 58
#### 10.4 Hardware Ability Constraint . . . . . . . . . . . . . . . . . . . . . . 58
#### 10.5 Scaling Control Methodologies . . . . . . . . . . . . . . . . . . . . . 58
##### 10.5.1 Group Fixed . . . . . . . . . . . . . . . . . . . . . . . . . . . 59
##### 10.5.2 Group Moving . . . . . . . . . . . . . . . . . . . . . . . . . . 59
##### 10.5.3 Maximize DAC Currents . . . . . . . . . . . . . . . . . . . . . 59
##### 10.5.4 Time Scale Fixed . . . . . . . . . . . . . . . . . . . . . . . . . 60
#### 10.6 “Real Time” Scaling Control . . . . . . . . . . . . . . . . . . . . . . 60


## PART IV: Simulations of Mixed Signal Integration 61

### Chapter 11 Simulator Design 62
#### 11.1 Simulator Program . . . . . . . . . . . . . . . . . . . . . . . . . . . . 62
#### 11.2 Simulation Parameters . . . . . . . . . . . . . . . . . . . . . . . . . . 63

### Chapter 12 Simulations: First Order ODE’s 64
#### 12.1 Solution for dx/dt = 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . 64
##### 12.1.1 Effect of the Scaling Index . . . . . . . . . . . . . . . . . . . . 64
##### 12.1.2 Zero Crossing . . . . . . . . . . . . . . . . . . . . . . . . . . . 68
##### 12.1.3 Modified Denormalization . . . . . . . . . . . . . . . . . . . . 68
#### 12.2 Solution for dx/dt = −x . . . . . . . . . . . . . . . . . . . . . . . . . . . 70
#### 12.3 Solution for dx/dt = x^2 . . . . . . . . . . . . . . . . . . . . . . . . . . . 72

### Chapter 13 Simulations: Second Order ODE’s 74
#### 13.1 Second Order Linear Systems . . . . . . . . . . . . . . . . . . . . . . 74
