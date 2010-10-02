/**
 * FlexibleMatrix
 * A matrix calculation class for ActionScript 3
 * 
 * Original Date:	October 2009
 * Version: 		1.0, 02 Oct 2010
 * 
 * Author:			Lukas Domnick
 * 					<lukx@lukx.de>
 *					http://www.lukx.de/code/
 *
 * Copyright (c) 2009-2010 Lukas Domnick
 * Published under a BSD Open Source License
 * More Info: http://go.lukx.de/lukxbsd/
 *
 * This Project is hosted on GitHub: http://github.com/Lukx/FlexibleMatrix
 *
 * 
 * Ported from "Matrix Calculator" 1.6 by Marcus Kazmierczak, http://www.mkaz.com/math/
 * 
 * Disclaimer: To be honest, I have no clue what matrix math is about, which is why I in
 * many parts just ported Marcus' implementation to AS3 and tweaked it until
 * it worked. Now this is this.
 * 
 * You are invited to let me know if you find a way of improving this
 * class. gitHub or mail me :-)
 * 
 * Greetings from Cologne, Germany!
 * Come by and have a beer with me if you like this class :-)
 * 
 * 
 * Usage Example:
 * My favorite way to create matrices is the following:
 * 
 * var myMtx:FlexibleMatrix = new FlexibleMatrix();
 * myMtx.appendRow(2,4,6,2,1)
 * 		.appendRow(5,1,2,1,2)
 * 		.appendRow(1,5,1,1,1);
 * 
 * Results in the following matrix:
 * 
 * 		/ 2 4 6 2 1 \
 * 		| 5 1 2 1 2 |
 * 		\ 1 5 1 1 1 /
 * */
package de.lukx.math
{
	
	 
	public class FlexibleMatrix
	{
		/**
		 * @private
		 * Contains the actual matrix as a 2 dimensional Vector
		 * */
		private var actualMatrix:Vector.<Vector.<Number>>;
		private var actualMatrixColumns:int = 0;
		private var actualMatrixRows:int = 0;
		public var determinantFactor:int = 0; 
		private const DEBUG:Boolean = false;
					
		/**
		 * Creates a new FlexibleMatrix.
		 * 
		 * @param int columns
		 * @param int rows
		 * */
		public function FlexibleMatrix( columns:int = 0,
										rows:int = 0 ) {
			this.actualMatrixColumns = columns;
			this.actualMatrixRows = rows;

				// Weird notation but that's the way 2-dimensional Vectors work:
			this.actualMatrix = new Vector.<Vector.<Number>>( columns );
			
			for( var currentColumn:int = 0;
				 currentColumn < columns;
				 currentColumn++ ) {
				this.actualMatrix[currentColumn] =  new Vector.<Number>( rows );
			};
			
			debug("Constructing Matrix of size " + columns + "," + rows);
		}


		/**
		 * Fill a specified column with a number of values passed in a Vector,
		 * overwriting the existing column values.
		 * Notes:
		 * - The column needs to be created first! If you want to add a new
		 *   column, use function addColumn( values )
		 * - The values:Vector must contain exactly as many rows (read: values)
		 *   as the matrix itself.
		 * 
		 * @param int number of an existing column to fill (0-Based)
		 * @param ... 1-n values for that column, separated by comma
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object
		 * */
		public function setColumn( columnNumber:int,
								   ... values ):FlexibleMatrix {
			debug("Setting column no. " + columnNumber + " with " + values);
			// Do not fill colums which have not been declared!
			if ((columnNumber < 0 )
					|| ( columnNumber >= this.actualMatrixColumns )) {
				throw new ArgumentError( "Colum does not exist" );
			}
			
			// The input vector must be of the same length as the matrix' rows
			if( values.length != this.getDimensions().rows ) {
				throw new ArgumentError( "Input vector must contain the same" 
									+ " amount of rows as the matrix itself." )
			}
			for(var i:int = 0; i < values.length; i++) {
				if(!isNaN(values[i]))
					this.setValue(columnNumber,i,values[i]);
				else
					throw new ArgumentError( "Input value " + values[i] + " is NaN!" );
			}
			
			return this;
		}
		
		/**
		 * Fill a specified row with a number of values passed in a Vector,
		 * overwriting the existing row values.
		 * Notes:
		 * - The row needs to be created first! If you want to add a new
		 *   column, use function addRow( values )
		 * - The values:Vector must contain exactly as many columns (read: values)
		 *   as the matrix itself.
		 * 
		 * @param int number of an existing row to fill (0-Based)
		 * @param ... 1-n values for that row separated by comma
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object
		 * */
		public function setRow( rowNumber:int,
								... values ):FlexibleMatrix {
			// Do not fill colums which have not been declared!
			if ((rowNumber < 0 )
					|| ( rowNumber >= this.actualMatrixRows )) {
				throw new ArgumentError( "Row does not exist" );
			}
			// The input vectors must be of the same length as the matrix' columns
			if( values.length != this.getDimensions().columns ) {
				throw new ArgumentError( "Input vector must contain the same" 
								  + " amount of columns as the matrix itself." )
			}

			for(var i:int = 0; i < values.length; i++) {
				if(!isNaN(values[i]))
					this.setValue(i,rowNumber,values[i]);
				else
					throw new ArgumentError( "Input value " + values[i] + " is NaN!" );
			}
			return this;
		}
		
		/**
		 * Appends a column to the matrix and fills it with values from a Vector
		 * Note:
		 * - You must pass exactly as many values as there are rows in 
		 *   your matrix, unless this is the first row.
		 * 
		 * 
		 * @param ... values: the values for that column, separated by comma
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object
		 * 
		 * @example
		 * matrix.appendColumn(1,5,1,2);
		 * */
		public function appendColumn( ... values ):FlexibleMatrix {
			// If this is not the first column, the number of values must be
			// equal to the current matrix row number 
			if( (this.getDimensions().columns != 0 )
				&& (values.length != this.getDimensions().rows) ) {
				throw new ArgumentError( "Input vector must contain the same" 
									  + "amount of rows as the matrix itself." )
			}
			this.actualMatrixColumns = this.actualMatrix.push(
										  new Vector.<Number>( values.length )
			);
			this.actualMatrixRows = values.length;
			for( var i:int = 0; i < values.length; i++ ) {
				this.setValue( this.getDimensions().columns - 1 , i, values[i] );
			}
			return this;
		}

		/**
		 * Appends a row to the matrix and fills it with values from a Vector
		 * Note:
		 * - You must pass exactly as many values, as there are columns in
		 *   your matrix, unless this is the first row. 
		 * 
		 * @param values: the values for that row, seperated by comma
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object
		 * 
		 * @example (with chaining), my prefered way to set up a matrix
		 * matrix.appendRow(1, 4, 6, 1)
		 * 		 .appendRow(3, 4,16, 3);
		 * */
		public function appendRow( ... values ):FlexibleMatrix {
			// If this is not the first column, the number of values must be
			// equal to the current matrix row number 
			if( ( this.getDimensions().rows != 0 )
				&& ( values.length != this.getDimensions().columns ) ) {
				throw new ArgumentError( "Input vector must contain the same" 
								  + "amount of columns as the matrix itself." );
			}
			if( this.getDimensions().columns == 0 ) {
				this.actualMatrix = new Vector.<Vector.<Number>>( values.length );
				for( var i:int = 0; i < values.length; i++ ) {
					this.actualMatrix[i] = new Vector.<Number>;
				}
			}
			this.actualMatrixColumns = values.length;
			
			for( var j:int = 0; j < values.length; j++ ) {
				debug( "Appending value " + values[j] + " to column " + j );
				this.actualMatrixRows = this.actualMatrix[j].push( values[j] );
			}
			return this;
		}
		
		/*
		 DOES NOT WORK YET, unshift() somehow has its problems and doesn't seem
		 to extend the matrix.
		 
		 **
		 * Prepends a column to the matrix and fills it with values from a Vector
		 * Note:
		 * - The values:Vector must contain exactly as many rows (read: values)
		 *   as the matrix itself.
		 * 
		 * TODO: Not tested yet!!!
		 * 
		 * @param Vector.<Number> the values for that column
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object
		 * *
		public function prependColumn( ... values ):FlexibleMatrix {
			// If this is not the first column, the number of values must be
			// equal to the current matrix row number 
			if( (this.getDimensions().columns != 0 )
				&& (values.length != this.getDimensions().rows) ) {
				throw new ArgumentError( "Input vector must contain the same amount of rows as the matrix itself." )
			}
			trace("cols before: " + this.actualMatrix.length);
			this.actualMatrixColumns = this.actualMatrix.unshift(new Vector.<Number>( values.length ));
			trace("cols: " + this.actualMatrixColumns);
			this.actualMatrixRows = values.length;
			for(var i:int = 0; i < values.length; i++) {
				this.setValue(0,i,values[i]);
			}
			return this;
		} */

		/**
		 * Prepends a row to the matrix and fills it with values from a Vector
		 * Note:
		 * - The values:Vector must contain exactly as many columns (read: values)
		 *   as the matrix itself.
		 * 
		 * TODO: Not tested yet!!!
		 * 
		 * @param Vector.<Number> the values for that row
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object
		 * */
		public function prependRow( ... values ):FlexibleMatrix {
			// If this is not the first column, the number of values must be
			// equal to the current matrix row number 
			if( ( this.getDimensions().rows != 0 )
				&& ( values.length != this.getDimensions().columns ) ) {
				throw new ArgumentError( "Input vector must contain the same" 
								  + "amount of columns as the matrix itself." );
			}
			if( this.getDimensions().columns == 0 ) {
				this.actualMatrix = new Vector.<Vector.<Number>>( values.length );
				for( var i:int = 0; i < values.length; i++ ) {
					this.actualMatrix[i] = new Vector.<Number>;
				}
			}
			this.actualMatrixColumns = values.length;
			
			for( var j:int = 0; j < values.length; j++ ) {
				debug( "Prepending value " + values[j] + " to row " + j );
				this.actualMatrixRows = this.actualMatrix[j].unshift( values[j] );
			}
			return this;
		}
		
		/**
		 * Set a single value within the existing matrix
		 * 
		 * @param int colum number
		 * @param int row number
		 * @param Number value
		 * 
		 * @return FlexibleMatrix this FlexibleMatrix object 
		 * */
		
		public function setValue( columnNumber:int,
								  rowNumber:int,
								  value:Number ):FlexibleMatrix {
			debug("Setting Value in " + columnNumber + "," + rowNumber + " to " + value);
			if( ( columnNumber >= this.actualMatrixColumns )
				|| ( rowNumber >= this.actualMatrixRows ) ) {
				throw new ArgumentError( "The specified field (" + columnNumber + "," + rowNumber +") does not exist within this matrix." );
			}
			
			this.actualMatrix[columnNumber][rowNumber] = value;
			return this;
		}

		/**
		 * Get a single value from a specified field
		 * 
		 * @param int column number
		 * @param int row number
		 * 
		 * @return Number value of the specified field
		 * */
		public function getValue( columnNumber:int,
								  rowNumber:int ):Number {
			debug("Getting Value from " + columnNumber + "," + rowNumber);
			if(( columnNumber >= this.actualMatrixColumns )
				|| ( rowNumber >= this.actualMatrixRows ) ) {
				throw new ArgumentError( "The specified field does not exist within this matrix." );
			}
			debug( "\t=> is " + this.actualMatrix[columnNumber][rowNumber] ); 
			return this.actualMatrix[columnNumber][rowNumber];
		}
		
		
		/**
		 * Get the Matrix's dimensions in columns and rows
		 * 
		 * @return Object {columns:int,rows:int}
		 * */
		public function getDimensions():Object {
			var matrixDimensions:Object = { columns: this.actualMatrixColumns,
											rows:	 this.actualMatrixRows }
			debug( "Getting Matrix Dimensions: " + matrixDimensions.toString() );
			return matrixDimensions;
		}
		
		/**
		 * Gives a new object with the exact same values as this matrix holds.
		 * 
		 * @return FlexibleMatrix new cloned matrix object
		 */
		public function clone():FlexibleMatrix {
			var clonedMatrix:FlexibleMatrix = new FlexibleMatrix( this.getDimensions().columns,
												   this.getDimensions().rows );
			
			for ( var column:int = 0;
				  column < this.getDimensions().columns;
				  column++ ) {
				for ( var row:int = 0;
					  row < this.getDimensions().rows;
					  row ++ ) {
					clonedMatrix.setValue( column, row,
										   this.getValue( column, row ) );
				}
			}
			return clonedMatrix;
		}
		
		/**
		 * Add a matrix of the same dimensions of (this) to (this).
		 * 
		 * @param FlexibleMatrix the summand
		 * @return FlexibleMatrix a new result matrix object
		 */
		public function add( summand:FlexibleMatrix ):FlexibleMatrix {
			debug("Doing Addition");
			if(( summand.getDimensions().colums != this.getDimensions().colums )
				|| ( summand.getDimensions().rows != this.getDimensions().rows )) {
				throw new Error( "Both summands must have the same dimensions");
			}
			var resultMatrix:FlexibleMatrix;
			resultMatrix = new FlexibleMatrix( summand.getDimensions().columns,
											   summand.getDimensions().rows );
			// Iterate thru columns
			for ( var currentCol:int = 0;
				  currentCol < summand.getDimensions().columns;
				  currentCol ++ ) {
				  	
				// iterate thru this column's rows
				for ( var currentRow:int = 0;
					  currentRow < summand.getDimensions().rows;
				  	  currentRow ++ ) {
				  			
				  		// the actual math for each cell:
				  		var newValue:int = this.getValue( currentCol, currentRow ) 
				  	  			      + summand.getValue( currentCol, currentRow )
				  	  	resultMatrix.setValue( currentCol,
				  	  						   currentRow,
				  	  						   newValue );
				}
			}
			return resultMatrix;
		}
		
		
		/**
		 * Multiply another matrix with this matrix object. The number of columns
		 * in this matrix must be equal to the number of rows of the factor.
		 * 
		 * @param FlexibleMatrix the factor
		 * @return FlexibleMatrix the quotient matrix (new object)
		 */
		public function multiplyBy( factor:FlexibleMatrix ):FlexibleMatrix {
			debug( "Multiplying two Matrices..." );
			if ( this.getDimensions().columns != factor.getDimensions().rows ) {
				throw new Error("Matrices  incompatible for multiplication");
			}
			
			var resultMatrix:FlexibleMatrix = new FlexibleMatrix(
													factor.getDimensions().columns,
													this.getDimensions().rows
													);

			for ( var i:int = 0;
				  i < this.getDimensions().rows;
				  i++ ) {
				for ( var j:int = 0;
					  j < factor.getDimensions().columns;
					  j++) {
					resultMatrix.setValue( j, i, 0);
				}
			}
			
			for ( i = 0;
				  i < resultMatrix.getDimensions().rows;
				  i++ ) {
				for ( j = 0;
					  j < resultMatrix.getDimensions().columns;
					  j++ ) {
					resultMatrix.setValue(j, i,
									this.calculateRowColumnProduct(factor,i,j));
				}
			}
			
			return resultMatrix;
		}
		
		
		/**
		 * Calcluate the Row-Column-Product of two matrices.
		 * 
		 * @param FlexibleMatrix the other Matrix for the product
		 * @param int the row number (within this matrix object)
		 * @param int the column number (within the other matrix object)
		 * @return Number the Row-Column-Product
		 * 
		 */
		public function calculateRowColumnProduct( otherMatrix:FlexibleMatrix,
												   row:int,
												   column:int ):Number {
			var product:Number = 0;
			debug( "Calculating RowColumn-Product. Row: " 
												+ row + ", Col: " + column);
												
			for( var i:int = 0;
				 i < this.getDimensions().columns;
				 i++ ) {
				product += this.getValue( i, row)
							* otherMatrix.getValue( column, i );
			}
			return product;
		}
		
		/**
		 * Returns a new transposed matrix object based on this matrix object.
		 * Transposing simply means to switch columns and rows around.
		 * 
		 * @return FlexibleMatrix transposed FlexibleMatrix
		 **/
		public function transpose():FlexibleMatrix {
			
			var resultMatrix:FlexibleMatrix = new FlexibleMatrix(
													this.getDimensions().rows,
													this.getDimensions().columns);
			
			for ( var i:int = 0;
				  i < resultMatrix.getDimensions().rows;
				  i++ ) {
				for ( var j:int = 0;
					  j < resultMatrix.getDimensions().columns;
					  j++ ) {
					resultMatrix.setValue( j, i, this.getValue( i, j ) );
				}
			}
			return resultMatrix;
		}
		
		/**
		 * Inverse this matrix object and return the result as a new matrix
		 * object. Inversion is noted as A^(-1) on paper.
		 * 
		 * @return FlexibleMatrix a new matrix object of the inverted matrix.
		 */
		public function inverse():FlexibleMatrix {
			debug( "Inverting Matrix" );
			// Formula used to Calculate Inverse:
			// inv(A) = 1/det(A) * adj(A)
			if( this.getDimensions().rows != this.getDimensions().columns ) {
				throw new Error( "Only rectangular matrices may be inverted!" );
			}
			
			var matrixSideLength:int = this.getDimensions().rows;
			
			var resultMatrix:FlexibleMatrix = new FlexibleMatrix(
															matrixSideLength,
															matrixSideLength );
			var adjointMatrix:FlexibleMatrix = this.adjoint();
			var det:Number = this.determinant();
			var dd:Number = 0;
			
			if( det == 0 ) {
				debug( "Determinant Equals 0, thus not invertible." );
			} else {
				dd = 1 / det;
			}
			
			for ( var i:int = 0;
				  i < matrixSideLength;
				  i++ ) {
				for ( var j:int = 0;
					  j < matrixSideLength;
					  j++ ) {
					resultMatrix.setValue( j, i, 
										   dd * adjointMatrix.getValue( j, i ));
				}
			}
			
			return resultMatrix;
		}
		
		/**
		 * Performs an adjoint on this matrix.
		 * I don't know enough about math to understand what actually happens
		 * in here. But I ported the Java-Code from mkaz.com (see above) and
		 * it seems to work just fine.
		 * 
		 * @return FlexibleMatrix a new matrix object of the adjoint
		 */
		public function adjoint():FlexibleMatrix {
			debug( "Performing Adjoint..." );
			if( this.getDimensions().rows != this.getDimensions().columns ){
				throw new Error( "Only rectangular matrices may perform adjoint!" );
			}
			
			
			var matrixSideLength:int = this.getDimensions().rows;
			
			// This seem to be a couple of iterators
			var ii:int, jj:int, ia:int, ja:int;
			
			// det will store a couple of helpers matrix' determinants during
			// the loop.
			var det:Number;
			
			var resultMatrix:FlexibleMatrix = new FlexibleMatrix( 
														matrixSideLength,
														matrixSideLength );
			
			for ( var i:int = 0; i < matrixSideLength; i++ ) {
				for ( var j:int = 0; j < matrixSideLength; j ++ ) {
					
					ia = ja = 0;
					var helperMatrix:FlexibleMatrix = new FlexibleMatrix(
														  matrixSideLength - 1,
														  matrixSideLength - 1 );
															
					for( ii = 0; ii < matrixSideLength; ii ++ ) {
						for( jj = 0; jj < matrixSideLength; jj ++ ) {
							
							if( ( ii != i ) && ( jj != j ) ) {
								helperMatrix.setValue( ja, ia,
													   this.getValue( jj, ii ) );
								ja ++;
							}
							
						}
						if( ( ii != i ) && ( jj != j ) ) {
							ia++;
						}
						ja = 0;
					}
					
					det = helperMatrix.determinant();
					resultMatrix.setValue( j, i, Math.pow( -1, i + j ) * det );
					
				}
			}
			
			return resultMatrix.transpose();	
		}
		
		
		/**
		 * Returns a new FlexibleMatrix Object, representing the trigonalised
		 * version of this Matrix.
		 * 
		 * @return FlexibleMatrix Upper Triangulised Matrix
		 */ 
		public function upperTriangle():FlexibleMatrix {
			debug("Converting to Upper Triangle...");
	
			var f1:Number = 0;
			var temp:Number = 0;
			var tms:int = this.getDimensions().columns; // get This Matrix Size (could be smaller than
								// global)
			var v:int = 1;
			var resultMatrix:FlexibleMatrix = this.clone();
			resultMatrix.determinantFactor = 1;
	
			for (var col:int = 0; col < tms - 1; col++) {
				for (var row:int = col + 1; row < tms; row++) {
					v = 1;
					/*
	1 2 3 4
	3 5 1 4
	7 0 1 1
	7 0 1 1
					 */
					debug("WHILE col = " + col);
					while (resultMatrix.getValue(col,col) == 0) // check if 0 in diagonal
					{ // if so switch until not
						debug("I GOT HERE");
						if (col + v >= tms) // check if switched all rows
						{
							resultMatrix.determinantFactor = 0;
							debug("BROKE on col=" + col);
							break;
						} else {
							debug("DID NOT BREAK on col=" +col);
							for (var c:int = 0; c < tms; c++) {
								temp = resultMatrix.getValue(c,col);
								resultMatrix.setValue(c,col, resultMatrix.getValue(c,col+v)); // switch rows
								resultMatrix.setValue(c,col+v,temp);
							}
							v++; // count row switchs
							resultMatrix.determinantFactor= resultMatrix.determinantFactor* -1; // each switch changes determinant
											// factor
						}
					}
	
					if (resultMatrix.getValue(col,col) != 0) {

						debug("tms = " + tms + "   col = " + col
								+ "   row = " + row);

	
						try {
							f1 = (-1) * resultMatrix.getValue(col,row) / resultMatrix.getValue(col,col);
							for (var i:int = col; i < tms; i++) {
								resultMatrix.setValue(i,row, f1 * resultMatrix.getValue(i,col) + resultMatrix.getValue(i,row));
							}
						} catch ( e:Error) {
							debug("Still Here!!!");
						}
	
					}
	
				}
			}
	
			return resultMatrix;
		}
		
	
		/**
		 * Calculates the determinant of this matrix object. 
		 * 
		 * @return Number this matrix' determinant.
		 * */
		public function determinant():Number {
			debug( "Getting Determinant" );
			if( this.getDimensions().rows != this.getDimensions().columns ) {
				throw new Error( "Only rectangular matrices have a determinant!" );
			}
			
			var matrixSideLength:int = this.getDimensions().columns;
			var det:Number = 1;
			
			var detMatrix:FlexibleMatrix = this.upperTriangle();
			
			/*trace('uppertriangle');
			trace(detMatrix.toString());
			trace('/uppertriangle');*/
			for ( var i:int = 0;
				  i < matrixSideLength;
				  i++ ) {
				
				det = det * detMatrix.getValue( i, i );
			} // multiply down diagonally
			
			det = det * detMatrix.determinantFactor;
			debug( "Current Determinant-Factor: " + detMatrix.determinantFactor );
			debug( "Determinant is " + det );
			return det;
		}
		
		
		public function loadIdentity():FlexibleMatrix {
			if( this.getDimensions().rows != this.getDimensions().columns ) {
				throw new Error( "An identity matrix must be rectangular!" );
			} 
			for ( var column:int = 0;
				  column < this.getDimensions().columns;
				  column++ ) {
				for( var row:int = 0;
					 row < this.getDimensions().rows;
					 row ++) {
					if( column == row )
						this.setValue( column, row, 1 );
					else
						this.setValue( column, row, 0 );
				}
			}
			return this;
		}
		
		public function toString():String {
			var returnString:String = "";
			for( var currentRow:int = 0;
				 currentRow < this.actualMatrixRows;
				 currentRow ++ ) {
				// iterate over the rows
				
				for( var currentColumn:int = 0;
					 currentColumn < this.actualMatrixColumns;
					 currentColumn ++ ) {
					 	
					returnString += this.getValue( currentColumn, currentRow );
					if( currentColumn != this.actualMatrixColumns - 1 ) {
						returnString +=  "\t";
					}
				}
				
				returnString += "\n";
			}
			return returnString;
		}
		
		public function debug( message:String ):void {
			if( DEBUG )
				trace( "DEBUG: " + message );
		}
	}
}