package edu.macalester.comp124.breakout;


import comp124graphics.CanvasWindow;
import comp124graphics.GraphicsText;

import java.awt.*;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

/**
 * Main program for the breakout game.
 *Created by Hannah Detlaff
 */
public class
BreakoutGame extends CanvasWindow implements MouseListener, MouseMotionListener {

    private static final int CANVAS_WIDTH = 800;
    private static final int CANVAS_HEIGHT = 1000;
    private static final int PADDLE_Y = 850;
    private static final int TEXT_X = 100;
    private Ball ball;
    private Paddle paddle;
    private BrickWall brickWall;
    private Ball life1;
    private Ball life2;
    private Ball life3;
    private int MOVEPAUSE = 17;
    private int dx = -5;
    private int dy = -5;
    private boolean dead = false;
    private GraphicsText label;
    private String LoseText = "GAME OVER";
    Point lastLocation;

    public BreakoutGame() {
        super("Breakout!", CANVAS_WIDTH, CANVAS_HEIGHT);
        ball = new Ball();
        paddle = new Paddle(350, PADDLE_Y, 20, 150);
        brickWall = new BrickWall(2,75);
        lastLocation= new Point(350,850);
        addMouseListener(this);
        addMouseMotionListener(this);
        life1 = new Ball();
        life2 = new Ball();
        life3 = new Ball();

        add(paddle);
        add(brickWall);
        add(life1, 5,5);
        add(life2, 10+life2.getWidth(),5);
        add(life3, 15+life3.getWidth()*2, 5);
        run();

    }

    /**
     * Controls the basic loop that the game runs in accounting for three lives,
     * and then looping until the ball is dead
     */
    public void run(){
        for(int lives = 3; lives>0; lives--){
            add(ball, 400, 500);
            pause(3000);
            dead = false;
            while(!dead){
                advanceOneTimeStep();
                checkIfDead();
                if(brickWall.getCount()==0) {
                    break;
                }
            }
            if(lives==3){
                remove(life3);
            } else if(lives==2){
                remove(life2);
            } else if(lives==1){
                remove(life1);
            }
        }
        if(brickWall.getCount()!=0) {
            label = new GraphicsText(LoseText, (float) TEXT_X, 500.0f);
            label.setFont(new Font("SanSerif", Font.PLAIN, 100));
            add(label);
        }
    }

    /**
     * Moves the ball, pauses and checks and reacts if the ball has hit anything
     */
    public void advanceOneTimeStep(){
        ball.move(dx,dy);
        pause(MOVEPAUSE);
        ifBallHitsEdge();
        ifBallHitsBrick();
        ifBallHitsPaddle();
    }

    /**
     * in the event that the ball hits the top, left, or right wall, it causes the ball to bounce
     */
    public void ifBallHitsEdge(){
        if(ball.getX()+ball.getWidth()>=CANVAS_WIDTH || ball.getX()<0){
            dx=-dx;
        }
        if(ball.getY()<=0){
            dy=-dy;
        }
    }

    /**
     * Checks if the ball has hit a brick, and if it has removes the brick and bounces the ball.
     */
    public void ifBallHitsBrick(){
        Brick brick1 =brickWall.getBrickAt(ball.getX()+ball.getWidth()/2,ball.getY());
        Brick brick2 =brickWall.getBrickAt(ball.getX(),ball.getY()+ball.getWidth()/2);
        Brick brick3 =brickWall.getBrickAt(ball.getX()+ball.getWidth(),ball.getY()+ball.getWidth()/2);
        Brick brick4 =brickWall.getBrickAt(ball.getX()+ball.getWidth()/2,ball.getY()+ball.getWidth());
        if(brick1!=null ){
            brickWall.removeBrick(brick1);
            dy=-dy;
        }
        if(brick2!=null){
            brickWall.removeBrick(brick2);
            dx=-dx;
        }
        if(brick3!=null){
            brickWall.removeBrick(brick3);
            dx=-dx;
        }
        if(brick4!=null){
            brickWall.removeBrick(brick4);
            dy=-dy;
        }
    }

    /**
     * Checks if the ball has hit the paddle, and causes the ball to bounce if it has.
     * if the ball hits on the left side of the paddle it bounces to the left
     * if it hits on the right side it bounces to the right
     */
    public void ifBallHitsPaddle(){
        if(ball.getY()==PADDLE_Y-paddle.getHeight() && ball.getX()>=paddle.getX() && ball.getX()+ball.getWidth()<=paddle.getX()+paddle.getWidth()){
            dy=-dy;
            if(ball.getX()<paddle.getX()+paddle.getWidth()/2){
                dx=-Math.abs((int)dx);
            } else {
                dx=Math.abs((int)dx);
            }

        }
    }

    /**
     * checks to see if the ball has gone below the paddle at which point it is dead.
     */
    public void checkIfDead(){
        if(ball.getY()>PADDLE_Y){
            dead=true;
        }
    }
    @Override
    public void mousePressed(MouseEvent e) {
    }
    @Override
    public void mouseDragged(MouseEvent e) {
    }
    @Override
    public void mouseClicked(MouseEvent e) {
    }
    @Override
    public void mouseReleased(MouseEvent e) {

    }
    @Override
    public void mouseEntered(MouseEvent e) {

    }
    @Override
    public void mouseExited(MouseEvent e) {

    }

    /**
     * Moves the paddle with the mouse.
     * @param e
     */
    @Override
    public void mouseMoved(MouseEvent e) {
        paddle.move(e.getX() - lastLocation.getX(), 0);
        lastLocation = e.getPoint();
    }



}
