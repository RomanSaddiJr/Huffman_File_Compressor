# Huffman_File_Compressor
This program showcases an implementation of a Huffman compression algorithm computed in Ada.

## How It's Made:

**Tools used:** Ada, C++

This implementation of the Huffman Compression Algorithm explores the intricacies of Ada in comparison to other high leveled programming langauges through the development of a compression algorithm. This project in particular heavilty utilizes Ada's 'Strong Typing' and explicit type conversions, as well as Ada's built-in priority queue and interface packages.

## Contents:
This repository contains the files:

'file_compressor.adb': This Ada reads the input file and performs a Huffman compression algorithm on its content. This involves creating a Frequency table from the contents of the input file and using that to build a Huffman Tree. The Huffman Code is derived from this tree, which is then used to encode the original input string into a Huffman encoded string which is written into "output.txt".

'write_to_binary.cpp': This simple C++ program writes the contents of "output.txt" into the binary file "output.bin".

'input.txt': Write anything into this file to change input.

'output.txt': container for the huffman encoded message.

'output.bin': container for the binary huffman encoded message.

