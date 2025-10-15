submit: 
	cd part_1_combinational && make all
	cd part_1_combinational && ./AluTest 2>&1 | tee ../output1.log
	cd part_1_combinational && ./ArbiterTest 2>&1 | tee ../output2.log
	cd part_1_combinational&& ./ShifterTest 2>&1 | tee ../output3.log
	cd part_2_vector_multiply && make all
	cd  part_2_vector_multiply && ./TbVD 2>&1 | tee ../output4.log
	cat output1.log output2.log output3.log output4.log > output.log
	git add -A
	git commit -am "Save Changes & Submit"
	git push
