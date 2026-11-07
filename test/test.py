# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer


async def reset_dut(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


async def press_enter(dut, number, operator=0):
    """Present a number/operator and generate one enter-button press."""
    await FallingEdge(dut.clk)
    dut.ui_in.value = number
    dut.uio_in.value = (operator << 1) | 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # Release the button and allow the enter state machine to re-arm.
    await FallingEdge(dut.clk)
    dut.uio_in.value = operator << 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


async def start_test(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset_dut(dut)


@cocotb.test()
async def test_addition(dut):
    """Enter 12, then +, then 30; the displayed result should be 42."""
    await start_test(dut)
    await press_enter(dut, 12)
    await press_enter(dut, 0, operator=0b001)
    await press_enter(dut, 30)
    assert int(dut.uo_out.value) == 42


@cocotb.test()
async def test_subtraction(dut):
    """Enter 50, then -, then 8; the displayed result should be 42."""
    await start_test(dut)
    await press_enter(dut, 50)
    await press_enter(dut, 0, operator=0b010)
    await press_enter(dut, 8)
    assert int(dut.uo_out.value) == 42


@cocotb.test()
async def test_multiplication(dut):
    """Enter 6, then *, then 7; the displayed result should be 42."""
    await start_test(dut)
    await press_enter(dut, 6)
    await press_enter(dut, 0, operator=0b011)
    await press_enter(dut, 7)
    assert int(dut.uo_out.value) == 42


@cocotb.test()
async def test_chained_calculation(dut):
    """Check that a completed result can be used in the next operation."""
    await start_test(dut)
    await press_enter(dut, 10)
    await press_enter(dut, 0, operator=0b001)
    await press_enter(dut, 2)
    assert int(dut.uo_out.value) == 12

    await press_enter(dut, 0, operator=0b011)
    await press_enter(dut, 3)
    assert int(dut.uo_out.value) == 36

    await press_enter(dut, 0, operator=0b010)
    await press_enter(dut, 2)
    assert int(dut.uo_out.value) == 34


@cocotb.test()
async def test_squareroot(dut):
    """Enter 16, then square root; the displayed result should be 4."""
    await start_test(dut)
    await press_enter(dut, 16)
    await press_enter(dut, 0, operator=0b101)
    assert int(dut.uo_out.value) == 4


@cocotb.test()
async def test_exp(dut):
    """Enter 16, then square root; the displayed result should be 4."""
    await start_test(dut)
    await press_enter(dut, 2)
    await press_enter(dut, 0, operator=0b110)
    assert int(dut.uo_out.value) == 7

@cocotb.test()
async def test_loge(dut):
    """Enter 16, then square root; the displayed result should be 4."""
    await start_test(dut)
    await press_enter(dut, 55)
    await press_enter(dut, 0, operator=0b111)
    assert int(dut.uo_out.value) == 4
