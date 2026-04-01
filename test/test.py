import cocotb
from cocotb.triggers import Timer

async def clock_gen(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")

@cocotb.test()
async def test_all(dut):

    cocotb.start_soon(clock_gen(dut))  # ✅ now valid

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await Timer(20, units="ns")
    dut.rst_n.value = 1

    for i in range(10):
        dut.ui_in.value = i
        dut.uio_in.value = i + 1

        await Timer(20, units="ns")

        print(f"A={i}, B={i+1}, OUT={dut.uo_out.value}")
