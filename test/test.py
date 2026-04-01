import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_all(dut):

    # Start clock
    cocotb.start_soon(clock_gen(dut))

    # Init signals
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
