`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:45:25 12/04/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze #( parameter maze_width = 6)(

input 		                  clk,
input [maze_width - 1:0]      starting_col, starting_row, 	   // indicii punctului de start
input  			               maze_in, 			               // ofera informa?ii despre punctul de coordonate [row, col]
output reg [maze_width - 1:0] row, col,	 		               // selecteaza un rând si o coloana din labirint
output reg			            maze_oe,			                  // output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
output reg			            maze_we, 			               // write enable (activeaza scrierea în labirint la rândul ?i coloana date) - semnal sincron
output reg			            done);		 	                  // ie?irea din labirint a fost gasita; semnalul ramane activ 
  
//starile automatului

`define starea_de_plecare  10
`define orientarea         11
`define repozitionarea     12
`define iesirea            13

//orientarea dupa care se efectueaza deplasarea

`define est  0
`define nord 1
`define vest 2
`define sud  3

//starile automatului
reg [5:0] state = `starea_de_plecare; //stochez starea curenta
												  //initializez starea initiala cu starea `starea_de_plecare
reg [5:0] next_state ; //folosit pt calcularea starii urmatoare
																	

reg [maze_width - 1:0] row_aux, col_aux; //variabile auxiliare in care salvez coordonatele starii anterioare 

reg [1:0] orientare = `est; //variabila ce retine orientarea dupa care se efectueaza deplasarea

//partea secventiala
always @(posedge clk) begin
	if(done == 0)
		state <= next_state;
end

//partea combinationala
always @(*) begin

	 maze_we = 0;
	 maze_oe = 0;
	 done = 0;
	 
	 case(state)

			`starea_de_plecare: begin
				
				//initializez row, col si var aux cu indicii pct de plecare
				row = starting_row;
				col = starting_col;
				row_aux = starting_row;
				col_aux = starting_col;
				
				//marchez poz de intrare in labirint
				maze_we = 1;
			
				next_state = `orientarea;
			end
			
			
			`orientarea: begin
			//stabilesc modul in care ma orientez si deplasez
			
				//salvez in var aux coordonatele poz actuale
				row_aux = row;
				col_aux = col;
				
				case (orientare)
				//modific coordonatele poz actuale conform modului de deplasare
				
					`est: col = col + 1; 
					
					`nord: row = row - 1; 
					
					`vest: col = col - 1; 
					
					`sud: row = row + 1; 
					
				endcase
				
				//activez citirea din labirint pt randul si coloana date
				maze_oe = 1;
				
				next_state = `repozitionarea;
			end


			`repozitionarea: begin
			//evaluez pozitia pe care m-am deplasat
			
				if(maze_in == 0)begin 
				//nu am dat de perete
				
					maze_we = 1; //marchez poz
					
					//ma repozitionez
					if(orientare > 0)
						orientare = orientare - 1;
					else orientare = `sud;
					
				next_state = `iesirea;
				end
				
				else begin
				//am dat de perete
				
					//ma intorc in pozitia anterioara salvata in var aux
					row = row_aux;
					col = col_aux;
					
					//ma repozitionez
					if(orientare < 3)
					   orientare = orientare + 1;
					else orientare = `est;
					
					next_state = `orientarea;
				
				end
				
			end
			
			
			`iesirea: begin
			//verific daca am ajuns sau nu la iesirea din labirint
				
				if(row == 0 || row == 63 || col == 0 || col == 63) 
					done = 1; //activez done, parcurgerea s-a incheiat
							
				else next_state = `orientarea;
							
			
			 end
			
	endcase
	
end

endmodule


