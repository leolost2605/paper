/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.PenButton : Granite.Bin {
    public Pen pen { get; construct; }

    private PenPopover popover;

    public PenButton (Pen pen) {
        Object (pen: pen);
    }

    construct {
        child = new Gtk.Image.from_icon_name ("edit") {
            pixel_size = Penbar.ICON_SIZE,
        };

        popover = new PenPopover (pen);
        popover.set_parent (this);

        var gesture_click = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY
        };
        gesture_click.released.connect (popover.popup);
        add_controller (gesture_click);
    }

    ~PenButton () {
        popover.unparent ();
    }
}
