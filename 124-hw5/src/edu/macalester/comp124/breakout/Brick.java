package edu.macalester.comp124.breakout;

import comp124graphics.Rectangle;

import java.awt.*;

/**
 * Created by 152ba on 3/23/2017.
 */
public class Brick extends Rectangle {
    private Color color;

    public Brick(double x, double y, double height, double width, Color color){
        super(x, y, height, width);
        this.color = color;
        setFilled(true);
        setFillColor(color);
    }

    @Override
    public String toString() {
        return "this is a " +color +" Brick";
    }



}
