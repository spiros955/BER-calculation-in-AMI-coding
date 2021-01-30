# BER-calculation-in-AMI-coding

This project took place for the course of *Intergrated Communication Systems* in 2018. 

# Description

Using **MATLAB** we simulated a digital communication system using the **Alternate Mark Inversion (AMI)** encoding technique. Our goal was to test the **bit-error-rate(BER)** performance on the receiver and compare it with the ΒΕR-SNR theoretical curve.

## Alternate Mark Inversion (AMI)

AMI is a synchronous clock encoding technique that uses bipolar pulses to represent logical 1. The next logic 1 is represented by a pulse of the opposite polarity. Hence a sequence of logical 1s are represented by a sequence of pulses of alternating polarity. 


![tttt](https://user-images.githubusercontent.com/59124127/106363476-74db2b80-6331-11eb-8034-719324213b2a.png)
###### *Example of AMI coding and the corresponding clock signal*

## Bit Error Rate (BER)

Bit error rate (BER) is defined as the percentage of bits that have errors relative to the total number of bits received in a transmission. BER is usually expressed as 10 to a negative power. The BER is calculated by comparing the transmitted sequence of bits to the received bits and counting the number of errors. 

## Signal-to-Noise Ratio 

Signal-to-noise ratio (SNR or S/N) is a measure used in science and engineering that compares the level of a desired signal to the level of background noise. SNR is defined as the ratio of signal power to the noise power, often expressed in decibels. A ratio higher than 1:1 (greater than 0 dB) indicates more signal than noise.

## Additive White Gaussian Noise (AWGN)

Additive white Gaussian noise (AWGN) is a basic noise model used in information theory to mimic the effect of many random processes that occur in nature. The modifiers denote specific characteristics:

**Additive** because it is added to any noise that might be intrinsic to the information system.

**White** refers to the idea that it has uniform power across the frequency band for the information system. It is an analogy to the color white which has uniform emissions at all frequencies in the visible spectrum.

**Gaussian** because it has a normal distribution in the time domain with an average time domain value of zero.
