
# AXI-Stream Protocol Verification

This repository contains a UVM-based verification environment for the AXI-Stream interface protocol. The purpose of this project is to verify that a DUT implementing the AXI-Stream protocol behaves correctly in terms of data transfer, handshaking, and packet signaling.

---

## Overview

AXI-Stream is a unidirectional, high-performance streaming interface that uses a simple handshake mechanism:

* `TVALID` indicates data validity
* `TREADY` controls flow and back-pressure
* Optional signals such as `TLAST` indicate packet boundaries

The verification environment tests DUT compliance with these protocol rules under a variety of randomized and directed scenarios.

---

## UVM Components

The verification environment includes:

### Sequence Item

Defines the transaction structure used for AXI-Stream transfers (data values, optional `TLAST`, etc.). Supports constrained randomization of packet contents and lengths.

### Sequence

Generates sequences of AXI-Stream transactions for different stimulus patterns.

### Driver

Drives the AXI-Stream signals to the DUT according to the protocol, handling handshaking and data flow.

### Monitor

Observes DUT signal activity and forwards captured transactions for checking.

### Scoreboard

Compares monitored DUT outputs with expected results produced by the reference model. Reports mismatches.

### Agent

Bundles sequencer, driver, and monitor into a reusable AXI-Stream verification component.

### Environment

Connects the agent with the scoreboard and manages the overall verification flow.

### Test

Configures the environment and executes sequences to verify protocol behavior.

---

## Verification Focus

The environment verifies:

* Correct use of `TVALID` / `TREADY` handshake
* Proper data transfer under normal and back-pressure conditions
* Correct assertion of `TLAST` for packet completion
* Ordering and integrity of packetized data
* Handling of randomized and directed input patterns

The testbench is self-checking and reports protocol violations or mismatches detected by the scoreboard.

---

## Features

* Standard UVM architecture
* Constrained-random and directed stimulus support
* Self-checking testbench with reference model
* Verification of handshaking, packet boundaries, and flow control
* Modular structure, easily extendable for additional AXI-Stream features


If you want, I can also prepare a short verification plan or a more formal documentation section for your repository.
