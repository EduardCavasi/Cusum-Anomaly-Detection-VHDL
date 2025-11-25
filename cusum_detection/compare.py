import os
py_dir = "python_csv_files"
fpga_dir = "fpga_csv_files"

py_files = os.listdir(py_dir)

for file in py_files:
    py_ans = []
    fpga_ans = []
    file_path = os.path.join(py_dir, file)
    if os.path.isfile(file_path):
        with open(file_path, 'r') as f:
            for line in f:
                content = line.split(", ")
                py_ans.append(int(content[-1]))
        fpga_file_path = os.path.join(fpga_dir, file.replace("python", "fpga"))
        with open(fpga_file_path, 'r') as f:
            for line in f:
                content = line.split(", ")
                fpga_ans.append(int(content[-1]))

        print("Sensor " + file.split("_")[-1].replace(".csv", "") + ": ")
        diff = 0
        for i in range(len(py_ans)):
            if py_ans[i] != fpga_ans[i]:
                diff += 1
        print("Differences: " + str(diff) + "\n")


