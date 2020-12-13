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
The first parameter indicates the AI's strength, I suggest putting in 9 or 7. The second parameter indicates the player who goes first. 2 means the player goes first; 1 means the AI goes first.

On my MacBook Pro, The AI takes around 1 second to figure out each move, though it might take longer on the first two moves. If it takes too long on your computer, try setting the AI strength to 7 instead of 9. 
