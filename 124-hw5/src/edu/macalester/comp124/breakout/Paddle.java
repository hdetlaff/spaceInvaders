package edu.macalester.comp124.breakout;

import comp124graphics.Rectangle;

import java.awt.*;

/**Tis a rectangle
 * Created by Hannah Detlaff on 3/23/2017.
 */
public class Paddle extends Rectangle {

    public Paddle(double x, double y, double height, double width) {
        super(x, y, width, height);
        setFilled(true);
        setFillColor(Color.BLACK);
    }

}
