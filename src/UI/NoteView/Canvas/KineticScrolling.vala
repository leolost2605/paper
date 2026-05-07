/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Adapted from GTK 4's kinetic scrolling implementation, see:
 * https://gitlab.gnome.org/GNOME/gtk/-/blob/main/gtk/gtkkineticscrolling.c
 */
public class Quicknote.KineticScrolling : Object {
    private const double USEC_PER_SEC = 1000000.0;

    public int64 frame_time { get; construct; }
    public double position { get; construct set; }
    public double velocity { get; construct set; }
    public double decel_friction { get; construct; }

    private double c1;
    private double c2;

    public KineticScrolling (int64 frame_time, double initial_pos, double initial_velocity, double decel_friction) {
        Object (frame_time: frame_time, position: initial_pos, velocity: initial_velocity, decel_friction: decel_friction);
    }

    construct {
        c1 = velocity / decel_friction + position;
        c2 = -velocity / decel_friction;
    }

    public void tick (int64 current_time) {
        var t = (current_time - frame_time) / USEC_PER_SEC;

        var exp_part = Math.exp (-decel_friction * t);

        position = c1 + c2 * exp_part;
        velocity = c2 * -decel_friction * exp_part;
    }
}
