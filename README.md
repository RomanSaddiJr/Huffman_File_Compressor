# Huffman_File_Compressor
This program showcases an implementation of a Huffman compression algorithm computed in Ada.

![image](https://user-images.githubusercontent.com/105825537/236346037-37293dee-9139-45b5-8048-ac626e210c03.png)
![image](https://user-images.githubusercontent.com/105825537/236346136-df438852-4b26-4468-abff-963b8da6f4e3.png)

## How It's Made:

**Tools used:** Ada, C++

This implementation of the Huffman Compression Algorithm explores the intricacies of Ada relative to other high leveled programming langauges through the development of a compression algorithm. This project in particular heavily utilizes Ada's 'Strong Typing' and explicit type conversions, as well as Ada's built-in priority queue and interface packages.

## Contents:
This repository contains the files:

**'file_compressor.adb':** This Ada file reads the input file and performs a Huffman compression algorithm on its content. This involves creating a Frequency table from the contents of the input file and using that to build a Huffman Tree. The Huffman Code is derived from this tree, which is then used to encode the original input string into a Huffman encoded string which is written into "output.txt".

**'write_to_binary.cpp':** This simple C++ program writes the contents of "output.txt" into the binary file "output.bin".

**'input.txt':** Write anything into this file to change input.

**'output.txt':** container for the huffman encoded message.

**'output.bin':** container for the binary huffman encoded message.

## How to run:
Simply run the file **'file_compressor.adb'** to encode the contents of **'input.txt'** and have it stored in **'output.txt'**.
The binary encoded message will now be visible from there.

To witness the complete Huffman File Compression, you can then run the file **'write_to_binary.cpp'** to store the contents of **'output.txt'** into an actual binary file **'output.bin'**. The file **'output.bin'** contains the compressed data.

Reverse functions **Decode()** and **readBinary()** exist in both **'file_compressor.adb'** and **'write_to_binary.cpp'**, which can do the opposite of the active functions **Encode()** and **toBinary()**.

