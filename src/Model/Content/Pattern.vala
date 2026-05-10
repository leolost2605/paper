/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pattern : Object {
    public bool active { get; set; default = false; }

    public PatternStyle style { get; set; }
    public float width { get; set; default = 20; }
    public float height { get; set; default = 20; }
    public Gdk.RGBA? color { get; set; }

    construct {
        style = new GridStyle ();

        var color = Gdk.RGBA ();
        color.parse ("blue");
        this.color = color;
    }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (!active) {
            return;
        }

        style.snapshot (width, height, color, snapshot, bounds);
    }
}
