model=case39

    

GEN_FREQ_CTRL = ./gen_freq_ctrl.py
#GEN_VOLT_CTRL = ./gen_volt_ctrl.py
GEN_SEC_VOLT_CTRL = ./gen_sec_volt_ctrl.py
#GEN_GENERATORS = gen_generators.py
GEN_REC = gen_recorder.py

REC = recorder.rcd

SIM_DIR = simulations
PLOT_DIR = plot

DIR_cases = results_droop

create_ctrl: 
	if [ ! -d $(SIM_DIR) ]; then mkdir -p $(SIM_DIR); fi; \
	python3 $(GEN_FREQ_CTRL)  $(SIM_DIR)
	#python3 $(GEN_VOLT_CTRL) $(SIM_DIR)
	#python3 $(GEN_SEC_VOLT_CTRL) $(SIM_DIR)

create_gen:
	python3 $(GEN_GENERATORS) $(SIM_DIR)/

setup : create_ctrl
	#cp grid_models/$(model).py $(SIM_DIR)
	cp other/* $(SIM_DIR)
	cp events.evnt $(SIM_DIR)
	python3 $(GEN_REC) $(SIM_DIR)/$(REC)
	cp parameters.py $(SIM_DIR)
	cp parameters.py $(PLOT_DIR)
	cp test_bus.py $(SIM_DIR)
	
run: setup
	cd $(SIM_DIR); python3 test_bus.py

debug: setup
	cd $(SIM_DIR); python3  -m pdb test_bus.py


# code to run experiments changing parameters in the simulations
exp:
	$(MAKE) create_ctrl
	$(MAKE) create_gen
	cp grid_models/$(model).py $(SIM_DIR)
	cp test_bus.py $(SIM_DIR)
	#
	for x in nominal a b c ; do \
		echo "*** case $$x" ; \
		cp other/* $(SIM_DIR); \
		sed -i "s/^case.*/case = '$$x'/" $(SIM_DIR)/network.py; \
		cd $(SIM_DIR); python3 test_bus.py ; cd .. ; \
		if [ ! -d $(DIR_cases)/case_$$x ]; then mkdir -p $(DIR_cases)/case_$$x ; fi; \
		cp $(SIM_DIR)/results.npy $(DIR_cases)/case_$$x/ ; \
	done


power = $(shell seq 1 1 10  )



exp_droop:
	echo $(power)
	for x in $(power) ; do \
		echo "*** power: -$$x \n" ; \
		sed -i "s/^droop_const.*/droop_const = 10.0 ** -$$x/" $(GEN_SEC_VOLT_CTRL) ; \
		$(MAKE) run ; \
		if [ ! -d $(DIR_cases)/case_$$x ]; then mkdir -p $(DIR_cases)/case_$$x ; fi; \
		cp $(SIM_DIR)/results.npy $(DIR_cases)/case_$$x/ ; \
	done






