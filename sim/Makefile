# Directories relative to sim/
PROJECT_DIR = ..
SIM_DIR     = ../xsim
REPEATS 		?=1
SEED				?=1
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

# All UVM tests
TESTS = axi_burst_write_read_test \
        axi_wr_all_after_rd_all_test \
        axi_wr_rd_all_addr_test \
        axi_wr_rd_conc_test \
        axi_wr_rd_test \
        axi_wr_test

# Coverage directories
COV_DIR    = $(SIM_DIR)/coverage
COV_REPORT = $(COV_DIR)/report

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
		-cc_type sbct \
		-cc_db axi_code_cov \
		-cc_dir coverage \
		-cov_db_name axi_func_cov \
		-cov_db_dir coverage/func_runs \
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


# Regression result directory
REG_DIR = $(SIM_DIR)/regression
REG_LOG = $(REG_DIR)/regression_summary.log

.PHONY: regression regression-report

regression: elaborate
	@mkdir -p $(REG_DIR)
	@rm -f $(REG_LOG)
	@touch $(REG_LOG)
	@passed=0; failed=0; \
	for test in $(TESTS); do \
	    for i in $$(seq 1 $(REPEATS)); do \
	        seed=$$(( $(SEED) + i )); \
	        log="$(REG_DIR)/$${test}_$${i}.log"; \
	        echo "========================================"; \
	        echo "TEST=$$test RUN=$$i/$(REPEATS) SEED=$$seed"; \
	        echo "========================================"; \
	        if (cd $(SIM_DIR) && xsim $(SNAPSHOT) --runall \
	            --testplusarg UVM_TESTNAME=$$test \
	            --testplusarg UVM_VERBOSITY=$(VERBOSITY) \
							-sv_seed $$seed \
							-cov_db_dir coverage/func_runs \
							-cov_db_name $${test}_$${i}) 2>&1 | tee "$$log"; then \
	            if grep -q "UVM_ERROR :[[:space:]]*0" "$$log" && \
	               grep -q "UVM_FATAL :[[:space:]]*0" "$$log"; then \
	                echo "PASS: $$test run $$i" | tee -a $(REG_LOG); \
	                passed=$$((passed + 1)); \
	            else \
	                echo "CHECK: $$test run $$i; inspect $$log" | tee -a $(REG_LOG); \
	                failed=$$((failed + 1)); \
	            fi; \
	        else \
	            echo "FAIL: $$test run $$i; inspect $$log" | tee -a $(REG_LOG); \
	            failed=$$((failed + 1)); \
	        fi; \
	    done; \
	done; \
	echo "========================================" | tee -a $(REG_LOG); \
  echo "REGRESSION SUMMARY" | tee -a $(REG_LOG); \
  echo "Passed: $$passed" | tee -a $(REG_LOG); \
  echo "Failed/Check: $$failed" | tee -a $(REG_LOG); \
  echo "Total:  $$((passed + failed))" | tee -a $(REG_LOG); \
  echo "========================================" | tee -a $(REG_LOG); \
  $(MAKE) code-coverage-summary; \
	$(MAKE) functional-coverage-summary; \
  test $$failed -eq 0


.PHONY: code-coverage-summary

code-coverage-summary:
	@cd $(SIM_DIR) && xcrg \
		-cov_db_name axi_code_cov \
		-cov_db_dir coverage \
		-report_dir coverage/code_report \
		-report_format html \
		-log coverage/xcrg_code.log
	@echo ""
	@echo "========================================"
	@echo "         CODE COVERAGE SUMMARY"
	@echo "========================================"
	@awk '/Line Coverage Score/{printf "Line Coverage      : %s%%\n", $$4} \
	      /Branch Coverage Score/{printf "Branch Coverage    : %s%%\n", $$4} \
	      /Condition Coverage Score/{printf "Condition Coverage : %s%%\n", $$4} \
	      /Toggle Coverage Score/{printf "Toggle Coverage    : %s%%\n", $$4}' \
	      $(SIM_DIR)/coverage/xcrg_code.log
	@echo "========================================"

.PHONY: functional-coverage-summary

functional-coverage-summary:
	@cd $(SIM_DIR) && xcrg \
		-cov_db_dir coverage/func_runs \
		-merge_dir coverage/merged \
		-merge_db_name axi_regression_func \
		-report_dir coverage/functional_report \
		-report_format html \
		-log coverage/xcrg_functional.log >/dev/null
	@echo ""
	@echo "========================================"
	@echo "      FUNCTIONAL COVERAGE SUMMARY"
	@echo "========================================"
	@awk '/<b><font face=.verdana. size=.3.>Total Groups Coverage Summary<\/font><\/b>/ {found=1; next} \
	     found && /<td bgcolor=.#FFFFC2./ { \
	         if (match($$0, /[0-9]+\.[0-9]+/)) { \
	             print "Overall Functional Coverage: " substr($$0, RSTART, RLENGTH) "%"; \
	             exit; \
	         } \
	     }' \
	     $(SIM_DIR)/coverage/functional_report/functionalCoverageReport/dashboard.html
	@echo "========================================"
	@echo "HTML report: $(SIM_DIR)/coverage/functional_report/functionalCoverageReport/dashboard.html"
