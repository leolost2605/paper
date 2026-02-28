/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.PenPopover : Gtk.Popover {
    public Pen pen { get; construct; }

    public PenPopover (Pen pen) {
        Object (pen: pen);
    }

    construct {
        var color_chooser = new Gtk.ColorChooserWidget ();
        pen.bind_property ("color", color_chooser, "rgba", SYNC_CREATE | BIDIRECTIONAL);

        var width_label = new Granite.HeaderLabel (_("Width"));
        var width_scale = new Gtk.Scale.with_range (HORIZONTAL, 1, 10, 1);
        pen.bind_property ("width", width_scale.adjustment, "value", SYNC_CREATE | BIDIRECTIONAL);

        var width_box = new Granite.Box (VERTICAL, HALF);
        width_box.append (width_label);
        width_box.append (width_scale);

        var box = new Granite.Box (VERTICAL) {
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
        };
        box.append (color_chooser);
        box.append (width_box);

        child = box;
        position = RIGHT;
    }
}
