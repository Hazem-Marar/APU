from cocotb.clock import Clock
import cocotb
from cocotb.triggers import RisingEdge

@cocotb.test()
async def test_sbox(dut):

    # Start clock
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Apply reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Wait a few cycles in reset
    for _ in range(3):
        await RisingEdge(dut.clk)

    # Release reset
    dut.rst_n.value = 1

    # Apply input
    dut.ui_in.value = 0x53
    dut.uio_in.value = 0b10  # mode = 10

    # Wait for output to settle (VERY IMPORTANT)
    for _ in range(3):
        await RisingEdge(dut.clk)

    # Now read output
    result = dut.uo_out.value.to_unsigned()

    print(f"Output: {result:#x}")

    assert result == 0xED, f"Expected 0xED, got {result:#x}"
