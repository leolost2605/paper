/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.ColorCircle : Gtk.Widget {
    public Gdk.RGBA color { get; set; }

    class construct {
        set_css_name ("colorcircle");
    }

    construct {
        notify["color"].connect (queue_draw);
        overflow = HIDDEN;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var bounds = Graphene.Rect () {
            origin = { 0, 0 },
            size = { get_width (), get_height () }
        };

        snapshot.append_color (color, bounds);
    }
}
