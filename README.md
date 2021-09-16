# Gomoku (Five in a Row)
A Gomoku AI that can think 9 steps ahead. (An average human can think about 3 steps ahead.)

If you don't have Processing already installed, go to https://processing.org/download/ and download it.

Click on any .pde file and the entire project will load. Hit the play button to challenge the AI. To undo a step, press g.

<img src="https://github.com/RolandGao/Gomoku/blob/master/example.png" width="500"/>


## Customization
You can change who plays first and the AI strength by going into gomoku3_4/gomoku3_4.pde and changing the following line.
```java
game = new Game(9, 2);
```
The first parameter indicates the AI's strength, I suggest putting in 9 or 7. 

The second parameter indicates who is playing whom. 1 is AI vs Player, 2 is Player vs AI, 3 is AI vs AI, 4 is Player vs Player.

On my MacBook Pro, The AI takes around 1 second to figure out each move, though it might take longer on the first two moves. If it takes too long on your computer, try setting the AI strength to 7 instead of 9. 

## Competition
Our AI model can beat most if not all existing AI models, even when our AI goes second (aka when going white).

(yyjhao/HTML5-Gomoku)[https://github.com/yyjhao/HTML5-Gomoku] with over 60 stars. We win as white.

<img src="https://github.com/RolandGao/Gomoku/blob/master/Competitor1.png" width="500"/>

(Kesoyuh/Gomoku)[https://github.com/Kesoyuh/Gomoku] with over 150 stars. We win as white.

<img src="https://github.com/RolandGao/Gomoku/blob/master/Competitor2.PNG" width="500"/>

(gobang)[https://github.com/lihongxun945/gobang] with over 1.2k stars. We win as white.

<img src="https://github.com/RolandGao/Gomoku/blob/master/Competitor3.png" width="500"/>
