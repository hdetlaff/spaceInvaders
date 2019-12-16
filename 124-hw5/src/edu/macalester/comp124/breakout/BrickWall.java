package edu.macalester.comp124.breakout;

import comp124graphics.GraphicsGroup;
import comp124graphics.GraphicsText;

import java.awt.*;

/**
 * Creates a wall of bricks
 * Created by Hannah Detlaff on 3/23/2017.
 */
public class BrickWall extends GraphicsGroup {
    private final double SPACE= 5;
    private final double BRICK_HEIGHT= 30;
    private final double BRICK_WIDTH= 75;
    private double x;
    private double y;
    private int count= 100;
    private static final int TEXT_X = 150;
    private GraphicsText label;
    private String WinText = "YOU WIN!";

    public BrickWall(double x, double y){
        super(x,y);
        this.x=x;
        this.y=y;
        makeBricks();
    }

    /**support method for making the bricks by making two rows at a specified height
     * @param y
     * @param color
     */
    private void makeTwoRows(double y, Color color){
        for(int i=0; i<10; i++){
            for(int j=0;j<40; j+=35) {
                Brick brick = new Brick((BRICK_WIDTH + SPACE) * i, y+j, BRICK_WIDTH, BRICK_HEIGHT, color);
                add(brick);
            }
        }
    }

    /**
     * makes the bricks with the appropriate colors, takes care of positioning each row
     */
    public void makeBricks(){
        makeTwoRows(0, Color.RED);
        makeTwoRows((BRICK_HEIGHT+SPACE)*2, Color.ORANGE);
        makeTwoRows((BRICK_HEIGHT+SPACE)*4, Color.YELLOW);
        makeTwoRows((BRICK_HEIGHT+SPACE)*6, Color.GREEN);
        makeTwoRows((BRICK_HEIGHT+SPACE)*8, Color.CYAN);
    }

    /**
     * Important method for checking to see if the ball has hit a brick, since BreakoutGame
     * knows nothing about Bricks
     * @param x
     * @param y
     * @return
     */
    public Brick getBrickAt(double x, double y){
         if(getElementAt(x,y)!=null && getElementAt(x,y) instanceof Brick){
             return (Brick)getElementAt(x,y);
         } else {
             return null;
         }
    }

    /**
     * Essential for making Bricks disappear since BreakoutGame doesn't know what a Brick is.
     * @param brick
     */
    public void removeBrick(Brick brick){
        remove(brick);
        decrementCount();
        if(count==0){
            label = new GraphicsText(WinText, (float)TEXT_X, 500.0f);
            label.setFont(new Font("SanSerif", Font.PLAIN, 100));
            add(label);
        }
    }

    /**
     * Keeps track of how many bricks there are, when it is 0 the player has won.
     * @return
     */
    public int decrementCount(){
        count--;
        return count;
    }

    public int getCount() {
        return count;
    }
}
