with Ada.Text_IO; use Ada.Text_IO;

procedure main is

	Filename   : constant String := "../docs/Sudoku.dat";
	File       : File_Type;
	Line_Count : Integer := -1;
	type Sudoku is Array (0 .. 8, 0 .. 8) of Integer;
	Matrix : Sudoku;
	Matrix_Copy : Sudoku;
	type Boolean_Grid is Array (0 .. 8, 0 .. 8) of Boolean;

	Row : Integer := 0;
	Column : Integer := 0;

	Sudoku_Solved : Boolean := false;

	procedure Print_Grid(Matrix : in Sudoku) is
	begin
		Put_Line ("+------+------+------+");
		Put ("|");
		for i in 0 .. 8 loop --rows
			if (Row = 3) then
				Put_Line ("+------+------+------+");
				Row := 0;
			end if;
			Row := Row + 1;
			for j in 0 .. 8 loop --columns
				if (Column = 3) then
					Put ("|");
					Column := 0;
				end if;
				Column := Column + 1;

				if (((j+1) mod 9) = 0) then
					Put_Line (Natural'Image (Matrix(i, j)) & "|");
				else
					Put (Natural'Image (Matrix(i, j)));
				end if;
			end loop;	
		end loop;

		Put_Line ("+------+------+------+");
	end Print_Grid;

	function Find_Solved(Grid : Sudoku) return Boolean_Grid is
		Is_Solved: Boolean_Grid;
	begin
		for i in 0 .. 8 loop
			for j in 0 .. 8 loop
				if (Grid (i, j) = 0) then
					Is_Solved (i, j) := false;
				else
					Is_Solved (i, j) := true;
				end if;
			end loop;
		end loop;
 		return Is_Solved;
	end Find_Solved;

	
	function Is_Used_In_Row(Grid : in Sudoku; Grid_Copy : in Sudoku; Row : Integer; Col : Integer) return Boolean is
	begin
		--Put_Line ("Row:" & Integer'Image (Row));
		--Put_Line ("Col:" & Integer'Image (Col));
		for i in 0 .. 8 loop
			--Put_Line ("Grid_Copy(Row, i):" & Integer'Image (Grid_Copy(Row, i)));
			--Put_Line ("Grid(Row, Col):" & Integer'Image (Grid(Row, Col)));

			if (Grid_Copy(Row, i) = Grid(Row, Col)) then
				return false;	
			end if;			
		end loop;
		return true;
	end Is_Used_In_Row;

	function Is_Used_In_Col(Grid : in Sudoku; Grid_Copy : in Sudoku; Row : Integer; Col : Integer) return Boolean is
	begin
		--Put_Line ("Row:" & Integer'Image (Row));
		--Put_Line ("Col:" & Integer'Image (Col));
		for i in 0 .. 8 loop
			--Put_Line ("Grid_Copy(i, Col):" & Integer'Image (Grid_Copy(i, Col)));
			--Put_Line ("Grid(Row, Col):" & Integer'Image (Grid(Row, Col)));
			if (Grid_Copy(i, Col) = Grid(Row, Col)) then
				return false;	
			end if;			
		end loop;
		return true;
	end Is_Used_In_Col;

	function Is_Used_In_Grid(Grid : in Sudoku; Grid_Copy : in Sudoku; Row : Integer; Col : Integer) return Boolean is
		type Square_Grid is Array (0 .. 2, 0 .. 2) of Integer;
		Square : Square_Grid;

		r, c : Integer := 0;

		Square_Row : constant Integer := (Row - (Row mod 3));
		Square_Col : constant Integer := (Col - (Col mod 3));
	begin

		--Put_Line ("Row:" & Integer'Image (Row));
		--Put_Line ("Col:" & Integer'Image (Col));
		--Put_Line ("Grid(Row, Col):" & Integer'Image (Grid(Row, Col)));

		--Put_Line ("Square_Row:" & Integer'Image (Square_Row));
		--Put_Line ("Square_Col:" & Integer'Image (Square_Col));

		for i in Square_Row .. (Square_Row + 2) loop
			for j in Square_Col .. (Square_Col + 2) loop
			Square (r, c) := Grid_Copy (i, j);
			c := c + 1;
			end loop;
			r := r + 1;
			c := 0;
		end loop;
		
		for i in 0 .. 2 loop
			for j in 0 .. 2 loop
				Put(Integer'Image (Square (i, j)));
			end loop;
		end loop;

		Put_Line(" ");

		for i in 0 .. 2 loop
			for j in 0 .. 2 loop
				if (Square(i, j) = Grid(Row, Col)) then
					return false;
				end if;
			end loop;		
		end loop;
		return true;
	end Is_Used_In_Grid;

	function Solve(Grid : in out Sudoku; Grid_Copy : in out Sudoku) return Boolean is
		Is_Solved : constant Boolean_Grid := Find_Solved(Grid);
		Row, Col, k : Integer := 0;
		Back_Tracking : boolean := false;

	begin
		while ((k >= 0) and (k < 81)) loop
			--Put_Line(Integer'Image (k));

			Row := k/9;
			Col := k mod 9;

			if (not (Is_Solved(Row, Col))) then
				Grid(Row, Col) := Grid(Row, Col) + 1;

				--Put_Line("Grid-Boolean: " & Boolean'Image (Is_Used_In_Grid(Grid, Grid_Copy, Row, Col)));

				while (not (Is_Used_In_Row(Grid, Grid_Copy, Row, Col)) and not (Is_Used_In_Col(Grid, Grid_Copy, Row, Col)) and not (Is_Used_In_Grid(Grid, Grid_Copy, Row, Col)) and Grid (Row, Col) < 9) loop
					Grid (Row, Col) := Grid (Row, Col) + 1;
				end loop;

				--Put_Line("Grid: " & Integer'Image (Grid (Row, Col)));

				--Put_Line(Boolean'Image (Is_Used_In_Row(Grid, Grid_Copy, Row, Col)));
				--Put_Line(Boolean'Image (Is_Used_In_Col(Grid, Grid_Copy, Row, Col)));

				if (Grid (Row, Col) >= 9) then
					Grid (Row, Col) := 0;
					Back_Tracking := true;
				else
					Back_Tracking := false;
					Grid_Copy (Row, Col) := Grid (Row, Col);
				end if;
			end if;
			if (Back_Tracking) then
				k := k - 1;
			else
				k := k + 1;
			end if;
		end loop;
	
		return (k = 81);
	end Solve;
begin
	Open (File, In_File, Filename);
	
	while not End_Of_File (File) loop
		declare
			Line : constant String := Get_Line (File);
			Line_Length : constant Natural := Line'Length;
		begin
			Line_Count := Line_Count + 1;
			if (Line_Length = 9) then
				for i in 0 .. 8 loop
					Matrix (Line_Count, i) := Character'Pos(Line(i+1)) - 48;
					Matrix_Copy (Line_Count, i) := Character'Pos(Line(i+1)) - 48;
				end loop;
			end if;
		end;
	end loop;
	
	Close (File);

	Print_Grid(Matrix_Copy);

	Sudoku_Solved := Solve(Matrix, Matrix_Copy);

	if (Sudoku_Solved) then
		Put_Line ("Sudoku Solved!");
		New_Line ();
		Put_Line ("Please choose output for your solution.");
		New_Line ();
		Put_Line ("1. Print to Terminal");
		Put_Line ("2. Save to File");
	else
		Put_Line ("No Solution Found.");
	end if;

	Print_Grid(Matrix);

	
end main;


