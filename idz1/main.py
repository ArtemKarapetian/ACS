import subprocess

def main():
    tests = [
        "-1\n1\n1",
        "101\n1\n1",
        "100\n" + '\n'.join(map(str, range(100))),
        "50\n" + '\n'.join(map(str, range(50, 0, -1))),
        "10\n0\n1\n0\n1\n0\n1\n0\n0\n1\n1",
        "10\n-1234124\n124123\n2\n234235\n34234\n0\n0\n-234234\n2345\n12",
    ]


    for i in range(len(tests)):
        try:
            result = subprocess.run(["java", "-jar", "rars1_6.jar", "idz.asm"], input=tests[i], text=True, capture_output=True)
            print("Test number " + str(i + 1))
            print("User input:\n" + tests[i].replace('\n', ' '))
            print("\n" + result.stdout[234:])
        except subprocess.CalledProcessError as e:
            print(e)

if __name__ == "__main__":
    main()
