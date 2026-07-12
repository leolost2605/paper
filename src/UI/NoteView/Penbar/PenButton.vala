/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.PenButton : Granite.Bin {
    public Pen pen { get; construct; }

    public uint position { get; set; }

    private PenPopover popover;

    public PenButton (Pen pen) {
        Object (pen: pen);
    }

    construct {
        child = new ColorCircle () {
            width_request = Penbar.ICON_SIZE,
            height_request = Penbar.ICON_SIZE,
        };
        pen.bind_property ("color", child, "color", SYNC_CREATE);

        popover = new PenPopover (pen);
        popover.set_parent (this);
        bind_property ("position", popover, "tool-position", SYNC_CREATE);

        var gesture_click = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY
        };
        gesture_click.released.connect (popover.popup);
        add_controller (gesture_click);

        var gesture_long_press = new Gtk.GestureLongPress ();
        gesture_long_press.pressed.connect (popover.popup);
        add_controller (gesture_long_press);
    }

    ~PenButton () {
        popover.unparent ();
    }
}
