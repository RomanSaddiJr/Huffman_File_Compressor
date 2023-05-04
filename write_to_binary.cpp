#include <iostream>
#include <fstream>

using namespace std;

// create a function that writes binary from a .txt file into a .bin file
void toBinary(string inputFilename, string outputFilename) {
    ifstream inputFile(inputFilename, ios::binary);
    ofstream outputFile(outputFilename, ios::binary);

    char byte = 0, bitCount = 0;
    char inputChar;

    // Use bitwise operations to pack bits into Bytes
    while (inputFile.get(inputChar)) {
        if (inputChar == '0') {
            byte <<= 1;
            bitCount++;
        }
        else if (inputChar == '1') {
            byte <<= 1;
            byte |= 1;
            bitCount++;
        }

        if (bitCount == 8) {
            outputFile.write(&byte, 1);
            byte = 0;
            bitCount = 0;
        }
    }

    // If remaining bits are left, pad with 0's and write to file
    if (bitCount > 0) {
        byte <<= (8 - bitCount);
        outputFile.write(&byte, 1);
    }

    inputFile.close();
    outputFile.close();
}

// Create a function to read a binary file and return a string of its contents
string readBinary(string inputFilename) {
    ifstream inputFile(inputFilename, ios::binary);
    string binaryString;
    char byte;
    while (inputFile.read(&byte, 1)) {
        for (int i = 7; i >= 0; i--) {
            if ((byte >> i) & 1) {
                binaryString += '1';
            }
            else {
                binaryString += '0';
            }
        }
    }
    inputFile.close();

    return binaryString;
}

int main() {
    string inputFilename = "output.txt";
    string outputFilename = "output.bin";

    // Write binary file from text file
    toBinary (inputFilename, outputFilename);



    return 0;
}
