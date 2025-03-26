import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(SudokuApp());
}

class SudokuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SudokuScreen());
  }
}

class SudokuScreen extends StatefulWidget {
  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> fixedCells = List.generate(9, (_) => List.filled(9, false));

  @override
  void initState() {
    super.initState();
    generateSudoku();
  }

  void generateSudoku() {
    List<List<int>> solvedBoard = List.generate(9, (_) => List.filled(9, 0));
    solveSudoku(solvedBoard);
    removeNumbers(solvedBoard, 40);
    setState(() {
      board = solvedBoard;
      fixedCells =
          board.map((row) => row.map((cell) => cell != 0).toList()).toList();
    });
  }

  void removeNumbers(List<List<int>> grid, int count) {
    Random random = Random();
    int removed = 0;
    while (removed < count) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);
      if (grid[row][col] != 0) {
        grid[row][col] = 0;
        removed++;
      }
    }
  }

  bool solveSudoku(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (solveSudoku(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool isValid(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3, startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  void updateCell(int row, int col, int value) {
    if (!fixedCells[row][col]) {
      setState(() {
        board[row][col] = value;
      });
    }
  }

  bool checkWin() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0 ||
            !isValid(board, row, col, board[row][col])) {
          return false;
        }
      }
    }
    return true;
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Winner!"),
            content: Text("You did it!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  generateSudoku();
                },
                child: Text("New Game"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Sudoku"),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              "SUDOKU",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 4,
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1,
              ),
              shrinkWrap: true,
              itemCount: 81,
              itemBuilder: (context, index) {
                int row = index ~/ 9;
                int col = index % 9;
                return GestureDetector(
                  onTap: () {
                    if (!fixedCells[row][col]) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => NumberPickerDialog(
                              onNumberSelected: (num) {
                                updateCell(row, col, num);
                                if (checkWin()) showWinDialog();
                              },
                            ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color:
                          fixedCells[row][col]
                              ? Colors.grey[300]
                              : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        board[row][col] == 0 ? "" : board[row][col].toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: generateSudoku,
            child: Text("New Game"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: TextStyle(fontSize: 18),
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberPickerDialog extends StatelessWidget {
  final Function(int) onNumberSelected;

  NumberPickerDialog({required this.onNumberSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Выберите число"),
      content: Wrap(
        children: List.generate(9, (index) {
          return GestureDetector(
            onTap: () {
              onNumberSelected(index + 1);
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
