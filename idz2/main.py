import subprocess
import math

def main():
    tests = [
        "-1",
        "101\n1",
        "1.05\n-1.02234\n1234124124\n0.234532",
        "2.44\n-1212\n-0.5256436",
        "493\n-2324\n0",
        "493\n-2324\n0.0",
        "0.999999999",
        "-0.92342342",
        "-0.6",
        "0.4"
    ]


    for i in range(len(tests)):
        try:
            result = subprocess.run(["java", "-jar", "rars1_6.jar", "main_for_python.s"], input=tests[i], text=True, capture_output=True)
            print("Test number " + str(i + 1))
            print("User input:\n" + tests[i].replace('\n', ' '))
            final_line = result.stdout.split()[-7:]
            arcsin_risc_v = float(final_line[2])
            input_num = float(tests[i].split('\n')[-1])
            arcsin_python = math.asin(input_num)
            print(" ".join(final_line))
            if (input_num == 0 or 0.95 <= arcsin_python / arcsin_risc_v <= 1.05):
                print("Split is checked via python built-in script. It's normal")
            else:
                print("Split is checked via python built-in script. It's not normal :( ")
            print('\n')
        except subprocess.CalledProcessError as e:
            print(e)

if __name__ == "__main__":
    main()
