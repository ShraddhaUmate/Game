import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled4/ball.dart';
import 'package:untitled4/missile.dart';
import 'package:untitled4/player.dart';

import 'button.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
enum direction {LEFT , RIGHT }

class _HomePageState extends State<HomePage> {
  // Player variables
  static double playerX = 0;

  // missile variables
  double missileX = playerX;
  double missileHeight = 10;
  bool midShot = false;

  //ball variables
  double ballX = 0.5;
  double ballY = 0;
  var ballDirection = direction.LEFT;

  void startGame() {
    double time = 0;
    double height = 0;
    double velocity = 60;

    Timer.periodic(Duration(milliseconds: 10), (timer) {
      height = -5 * time * time + velocity * time;

      if (height < 0) {
        time = 0;
      }
      setState(() {
        ballY = heightToPosition(height);
      });


      if (ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
      }
      else if (ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }
      if (ballDirection == direction.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      }
      else if (ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }
      if (playerDies()) {
        timer.cancel();
        _showDialog();
      }


      time += 0.1;
    });
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Dead!!!"),
          );
        });
  }

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 < -1) {
        //do nothing
      } else {
        playerX -= 0.1;
      }

      //only make the x coordinate the same when it is not in the middle of a shot
      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (playerX + 0.1 > 1) {
        //do nothing
      } else {
        playerX += 0.1;
      }
      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void fireMissile() {
    if (midShot == false) {
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        // shots fired
        midShot = true;
        //missile grows till it hits the top of the screen
        setState(() {
          missileHeight += 10;
        });

        //stop missile when it reaches the top of screen
        if (missileHeight > MediaQuery
            .of(context)
            .size
            .height * 3 / 4) {
          resetMissile();
          timer.cancel();
        }

        // check if missile has hit the ball
        if (ballY > heightToPosition(missileHeight) &&
            (ballX - missileX).abs() < 0.03) {
          resetMissile();
          ballX = 5;
          timer.cancel();
        }
      });
    }
  }

  // converts heights to a coordinate
  double heightToPosition(double height) {
    double totalHeight = MediaQuery
        .of(context)
        .size
        .height * 3 / 4;
    double position = 1 - 2 * height / totalHeight;
    return position;
  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 0;
    midShot = false;
  }

  bool playerDies() {
    if ((ballX - playerX).abs() < 0.05 && ballY > 0.95) {
      return true;
    } else {
      return false;
    }
  }




  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event){
        if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)){
          moveRight();
        }
        if(event.isKeyPressed(LogicalKeyboardKey.space)){
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
              flex:3,
              child: Container(
            color: Colors.pink[100],
                child: Center(
                  child: Stack(
                    children:[
                      MyBall(ballX: ballX, ballY: ballY),
                      MyMissile(
                        height: missileHeight,
                        missileX: missileX,
                      ),
                      Myplayer(
                        playerX: playerX,
                      ),


                    ],
                  ),

                ),
          ),),
          Expanded(child: Container(
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  icon: Icons.play_arrow_outlined,
                  function: startGame,
                ),
                MyButton(
                  icon: Icons.arrow_back,
                  function: moveLeft,
                ),
                MyButton(
                  icon: Icons.arrow_upward,
                  function: fireMissile,
                ),
                MyButton(
                  icon: Icons.arrow_forward,
                  function: moveRight,
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

}
