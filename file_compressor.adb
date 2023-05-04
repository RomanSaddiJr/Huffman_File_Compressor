with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings; use Ada.Strings;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Containers.Bounded_Priority_Queues;
with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Containers.Generic_Array_Sort;
with Ada.Sequential_IO;

-- Main File Procedure
procedure File_Compressor is

----------------------------------------------------------
-- Declare types for files

   -- Declare file types
   Input_File : File_Type;
   Input_File_Name : constant String := "input.txt";
   Output_File : File_Type;
   Output_File_Name : constant String := "output.txt";


   -- "Line" and "File" will read and write each line of the plaintext files
   Line : Unbounded_String;
   File : Unbounded_String;


----------------------------------------------------------
-- Declare types for Frequency Table

   -- Declare Frequency tables for 256 ascii characters
   type Freq_Table is array(0 .. 255) of Integer;
   type Freq_Lookup is array(0 .. 255) of Character;
   type Freq_Code is array(0 .. 255) of Unbounded_String;

   -- Declare a Frequency Record to hold the Frequency and Lookup Table
   type FrequencyRecord is record
      Frequencies : Freq_Table;
      Lookup_Table : Freq_Lookup;
      Code : Freq_Code;
   end record;


----------------------------------------------------------
-- Declare types for Huffman Tree

   -- Define the record type for nodes
   type Node is record
      Symbol : Character;
      Frequency : Integer;
      Priority : Integer;

      -- points to two children nodes
      Left : access Node;
      Right : access Node;
   end record;

   -- create a pointer to the node to easily access the node
   type Node_Ptr is access Node;

-----------------------------------------------------------
-- Define some functions needed by the Priority Queue

   -- Retrieves the priority from a node for the priority queue
   function Get_Priority (Element : Node_Ptr) return Natural is
   begin
      return Element.Priority;
   end Get_Priority;

   -- Defines the order of priority in the priority queue
   function Before (Left, Right : Integer) return Boolean is
   begin
      return Left < Right;
   end Before;

   -- Defines a new package for queue_interfaces
   package Node_Queues is new Ada.Containers.Synchronized_Queue_Interfaces
     (Element_Type => Node_Ptr);

   -- Defines a new package for bounded prioirty queue specifying its parameters
   package Node_Priority_Queues is new Ada.Containers.Bounded_Priority_Queues
     (Queue_Interfaces => Node_Queues, -- Element Type
      Queue_Priority => Integer, -- in order 1,2,3 onwards
      Default_Capacity => 256);

   -- Create a new instance of Node_Priority_Queue
   My_Queue : Node_Priority_Queues.Queue;

   -- Createe a procedure to swap pointers in priority queue
   procedure Swap(obj1 : Node_Ptr; obj2 : Node_Ptr) is
      Object1 : Node_Ptr := obj1;
      Object2 : Node_Ptr := obj2;
      Temp_Object : Node_Ptr;

   begin
      -- Swap the values of Object1 and Object2
      Temp_Object := Object1;
      Object1 := Object2;
      Object2 := Temp_Object;
   end Swap;

----------------------------------------------------------------
-- Create a function that builds the huffman tree

   -- takes frequency table and returns pointer to the root node
   function Build_Tree (In_Table : FrequencyRecord) return Node_Ptr is
      use Node_Queues;
      use Node_Priority_Queues;

      -- function returns a pointer to a newly created node
      function New_Node (Symbol : Character; Frequency : Integer) return Node_Ptr is
         New_Node_Ptr : Node_Ptr := new Node;
      begin
         New_Node_Ptr.Symbol := Symbol;
         New_Node_Ptr.Frequency := Frequency;
         New_Node_Ptr.Priority := Frequency;
         New_Node_Ptr.Left := null;
         New_Node_Ptr.Right := null;
         return New_Node_Ptr;
      end New_Node;
      Node_Count : Natural := 0;

   begin

      -- Enqueue all pointers to the records of nodes
      for I in In_Table.Frequencies'Range loop
         if In_Table.Frequencies(I) /= 0 then
            My_Queue.Enqueue(New_Item => New_Node(In_Table.Lookup_Table(I), In_Table.Frequencies(I)));
            Node_Count := Node_Count + 1;
            Put_Line(In_Table.Lookup_Table(I) & " Added to Queue!!");
         end if;
      end loop;
      Put_Line(" ");

        -- Build the Huffman tree by repeatedly dequeuing the lowest frequency nodes and creating a new parent node in their place.
      while Node_Count > 1 loop
         declare
            Parent_Node_Ptr : Node_Ptr := new Node;
            Left_Node_Ptr : Node_Ptr;
            Right_Node_Ptr : Node_Ptr;

         begin

            -- Dequeue the two nodes with lowest frequency
            My_Queue.Dequeue (Left_Node_Ptr);
            My_Queue.Dequeue (Right_Node_Ptr);
            Left_Node_Ptr.Priority := Left_Node_Ptr.Frequency;
            Right_Node_Ptr.Priority := Right_Node_Ptr.Frequency;

            -- Create a new parent node out of the two dequeued nodes
            Put_Line("Dequeuing two least common nodes: " & Left_Node_Ptr.Symbol & Right_Node_Ptr.Symbol);
            Parent_Node_Ptr.Frequency := Left_Node_Ptr.Frequency + Right_Node_Ptr.Frequency;

            -- Perform swap when approaching root node
            if Node_Count > 2 then
               Parent_Node_Ptr.Left := Left_Node_Ptr;
               Parent_Node_Ptr.Right := Right_Node_Ptr;
               Parent_Node_Ptr.Priority := Parent_Node_Ptr.Frequency;
            end if;

            if Node_Count <= 2 then
               Parent_Node_Ptr.Left := Right_Node_Ptr;
               Parent_Node_Ptr.Right := Left_Node_Ptr;
               Parent_Node_Ptr.Priority := Parent_Node_Ptr.Frequency;
            end if;

            -- Print the Frequency of the new parent node
            Put_Line("Resulting parent Node has Frequency of: ");
            Ada.Text_IO.Put(Integer'Image(Left_Node_Ptr.Frequency + Right_Node_Ptr.Frequency));
            Put_Line("");

            -- Enqueue the parent node
            My_Queue.Enqueue(Parent_Node_Ptr);
            Node_Count := Node_Count - 1;

         end;
      end loop;

      -- Return the root pointer
      declare
         Root_Ptr : Node_Ptr;
      begin
         My_Queue.Dequeue (Root_Ptr);
         return Root_Ptr;

      end;

   end Build_Tree;



----------------------------------------------------------
-- DECLARE A FUNCTION TO COMPUTE THE FREQUENCY AND LOOKUP TABLE

-- Function takes an Input String and returns a FrequencyRecord
function FindFrequency(InputString : String) return FrequencyRecord is

      -- Declare an instance of Freq_Table and Freq_Lookup
      Table_Instance : Freq_Table := (others => 0);
      Lookup_Instance : Freq_Lookup := (others => Character'Val(0));

      -- Declare an instance of FrequencyRecord
      Result : FrequencyRecord;

      -- Create a cursor that records the current position in Lookup Table
      count : Integer := 0;

      -- Create a flag to signifiy when a repeat character is found
      Found : Boolean := False;

   begin

      -- Create a loop to iterate through the entire Input String
      for i in 1 .. InputString'Length loop

         -- Re-Initialize the found flag to "False"
         Found := False;

         -- Create a loop to check if the character "InputString(i) exists
         -- already in the lookup table
         for j in 0 .. Lookup_Instance'Length - 1 loop
            if InputString(i) = Lookup_Instance(j) then
               Found := True;
               exit;
            end if;
         end loop;

         -- If character is unique, create a new unique character instance
         if not Found then
            Lookup_Instance(count) := InputString(i);
            Table_Instance(count) := Table_Instance(count) + 1;
            count := count + 1;

         -- if character is not unique, add +1 to its frequency
         else
            for w in 0 .. Lookup_Instance'Length - 1 loop
               if Lookup_Instance(w) = InputString(i) then
                  Table_Instance(w) := Table_Instance(w) + 1;
               end if;
            end loop;
         end if;
      end loop;


      -- return the record "Result" with the Frequency and Lookup Table
      Result.Frequencies := Table_Instance;
      Result.Lookup_Table := Lookup_Instance;
      return Result;

   end FindFrequency;

----------------------------------------------------------
-- DECLARE A PROCEDURE TO PRINT THE CONTENTS OF THE RECORD


   -- table takes in a frequency record and prints each object
   procedure PrintTable(Table : in FrequencyRecord) is
   begin
      for b in Table.Frequencies'Range loop
         if Table.Frequencies(b) /= 0 then
            Put_Line(" ");
            Put_Line("Symbol: " & Table.Lookup_Table(b));
            Put_Line("Frequency: " & Integer'Image(Table.Frequencies(b)));
            Put_Line("Code: " & To_String(Table.Code(b)));
         end if;
      end loop;
      Put_Line(" ");
   end PrintTable;


   -- Procedure adds the huffman code to complete the Frequency_Record
   procedure AddCodes(Node1 : access Node; Code1 : String := "" ; Result : in FrequencyRecord; PlusCode : in out FrequencyRecord) is
      Index : Integer := 1;

   begin
      -- If node is leaf node
      if Node1.Left = null and Node1.Right = null then

         -- Fill in the code
         for p in result.Lookup_Table'Range loop
            if result.Lookup_Table(p) = Node1.Symbol then
               PlusCode.Code(p) := To_Unbounded_String(Code1);
            end if;
         end loop;

         -- import the already known frequency and symbol

         -- Fill in the frequency
         for q in result.Frequencies'Range loop
            PlusCode.Frequencies(q) := result.Frequencies(q);
         end loop;
         -- Fill in the lookup table
         for r in result.Lookup_Table'Range loop
            PlusCode.Lookup_Table(r) := result.Lookup_Table(r);
         end loop;

      else
         -- Traverse the left child, adding a 0 to the code
         if Node1.Left /= null then
            AddCodes(Node1.Left, Code1 & "0", Result, PlusCode);
         end if;

         -- Traverse the right child, adding a 1 to the code
         if Node1.Right /= null then
            AddCodes(Node1.Right, Code1 & "1", Result, PlusCode);
         end if;
      end if;

   end AddCodes;

   ------------------------------------------------------------
   -- Translate the original string to huffman code

   -- Encode the string into huffman code
   function Encode(string1 : in String ; ref_table : in FrequencyRecord) return Unbounded_String is
      Transcribed_File : Unbounded_String;
   begin
      for i in string1'Range loop
         for j in ref_table.Lookup_Table'Range loop
            if string1(i) = ref_table.Lookup_Table(j) then
               Transcribed_File := Transcribed_File & ref_table.Code(j);
            end if;
         end loop;
      end loop;
      -- Put_Line(To_String(Transcribed_File));
      return Transcribed_File;
   end Encode;


   -- Decode the huffman code binary into a string
   function Decode(string1 : in String ; ref_table : in FrequencyRecord) return Unbounded_String is
      Decoded_File : Unbounded_String;
      temp_string : Unbounded_String;

   -- Iterate through the binary string and store each element in temp_string
   -- When a code is found in temp_string, write its symbol to Decoded_File string and clear temp_string
   begin
      for i in string1'Range loop
         temp_string := temp_string & string1(i);
         for j in ref_table.Code'Range loop
            if To_String(temp_string) = ref_table.code(j) and
              To_String(ref_table.code(j)) /= "" then
               Decoded_File := Decoded_File & ref_table.Lookup_Table(j);
               temp_string := To_Unbounded_String("");
            end if;
         end loop;
      end loop;
      return Decoded_File;
   end Decode;

   --------------------------------------------------------


--==============================================================================
-- We can now begin the statements of "File_Compressor"
--==============================================================================
begin

   -- open the input and output files
   Open (Input_File, In_File, Input_File_Name);
   Open (Output_File, Out_File, Output_File_Name);

   -- iterate through the Input File line by line
   while not End_Of_File (Input_File) loop

      -- Save each line of the Input File into the "Line" variable
      Line := To_Unbounded_String (Get_Line (Input_File));

      -- Append "Line" to File + add ascii for new line
      -- Ada.Characters.Latin_1.CR is universal nl between Linux/Unix + Windows
      File := File & Line ;--& Ada.Characters.Latin_1.CR;

   end loop;

---------------------------------------------------------
-- Declare new types to create statements using local variables

   declare
      -- declare an instance of a frequency record to contain frequency + symbol
      MyFrequency : FrequencyRecord;

      -- declare another instance of frequency record to contain frequency + symbol + code
      Final_Table : FrequencyRecord;

      -- define a root pointer
      Root_Ptr : Node_Ptr;

   begin

      -- Create a frequency table from the input file
      MyFrequency := FindFrequency(To_String(File));

      -- Builds the Huffman tree and returns a pointer to its root
      Root_Ptr := Build_Tree(In_Table => (FindFrequency(To_String(File))));

      -- Adds the code to FrequencyRecord
      AddCodes(Root_Ptr, Result => MyFrequency, PlusCode => Final_Table);

      -- Print the Frequency + Symbol + Code
      PrintTable(Final_Table);

      -- Encode the input string using the frequency table + code
      File := Encode(To_String(File), Final_Table);

      -- You may decode the huffman code binary now, or run the .cpp program and
      -- write it to a .bin file to showcase compression

      --File := Decode(To_String(File), Final_Table);

   end;

--------------------------------------------------------------------------------
-- Write the variable "File" into the Output File and close the files

   -- Write the ascii binary into the .txt output file for showcase
   Put_Line (Output_File, To_String (File));

   -- To write to binary file to showcase compression, run write_to_binary.cpp

   -- Close the input and output file
   Close (Input_File);
   Close (Output_File);


end File_Compressor;

