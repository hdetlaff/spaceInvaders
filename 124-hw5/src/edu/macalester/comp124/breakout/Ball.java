package edu.macalester.comp124.breakout;

import comp124graphics.Ellipse;

import java.awt.*;

/**
 * A black ball uses the move function. Largely relies on inherited methods
 * Created by Hannah Detlaff on 3/23/2017.
 */
public class Ball extends Ellipse {

    public Ball( ){
        super(0,0, 20, 20);
        setFilled(true);
        setFillColor(Color.BLACK);
    }


}
