# Directories relative to sim/
PROJECT_DIR = ..
SIM_DIR     = ../xsim

RTL_FILELIST = ../rtl/rtl_filelist.f
TB_FILELIST  = filelist.f

TOP      = tb_top
SNAPSHOT = $(TOP)_sim

TEST      ?= axi_base_test
VERBOSITY ?= UVM_HIGH

XVLOG = xvlog
XVHDL = xvhdl
XELAB  = xelab
XSIM   = xsim

VIVADO_LIBS = -L noc_nps_v1_0_2 \
              -L noc_nmu_sim_v1_0_0 \
              -L noc_hbm_nmu_sim_v1_0_0 \
              -L xlconstant_v1_1_10 \
              -L noc_nsu_sim_v1_0_1 \
              -L emb_mem_gen_v1_0_11 \
              -L axi_bram_ctrl_v4_1_13 \
              -L unisims_ver \
              -L unimacro_ver \
              -L secureip \
              -L xpm

.PHONY: rtl-compile tb-compile compile elaborate run gui clean

all: run

# Compile Vivado-generated RTL
rtl-compile:
	cd $(SIM_DIR) && xvlog --incr --relax \
		-L uvm \
		-L noc_nps_v1_0_2 \
		-L emb_mem_gen_v1_0_11 \
		-L noc_nsu_sim_v1_0_1 \
		-L noc_hbm_nmu_sim_v1_0_0 \
		-L noc_nmu_sim_v1_0_0 \
		-prj vlog.prj
	cd $(SIM_DIR) && xvhdl --incr --relax -prj vhdl.prj

# Compile UVM testbench
tb-compile: rtl-compile
	cd ../xsim && xvlog -sv -work xil_defaultlib -L uvm -f ../sim/filelist.f

compile: tb-compile

# Elaborate UVM top
elaborate: compile
	cd $(SIM_DIR) && xelab --incr --debug all --relax \
		$(VIVADO_LIBS) -L uvm \
		--snapshot $(SNAPSHOT) \
		xil_defaultlib.$(TOP) xil_defaultlib.glbl

# Run test
run: elaborate
	cd $(SIM_DIR) && xsim $(SNAPSHOT) --runall \
		--testplusarg UVM_TESTNAME=$(TEST) \
		--testplusarg UVM_VERBOSITY=$(VERBOSITY)

# GUI
gui: elaborate
	cd $(SIM_DIR) && xsim $(SNAPSHOT) -gui \
		--testplusarg UVM_TESTNAME=$(TEST) \
		--testplusarg UVM_VERBOSITY=$(VERBOSITY)

# Clean generated simulation products
clean:
	rm -rf $(SIM_DIR)/xsim.dir
	rm -rf $(SIM_DIR)/.Xil
	rm -f $(SIM_DIR)/xvlog.log $(SIM_DIR)/xvhdl.log
	rm -f $(SIM_DIR)/xelab.log $(SIM_DIR)/xsim.log
	rm -f $(SIM_DIR)/$(SNAPSHOT).*
