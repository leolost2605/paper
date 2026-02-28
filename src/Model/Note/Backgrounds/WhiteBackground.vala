/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.WhiteBackground : Background {
    private static Gdk.RGBA color;

    static construct {
        color = Gdk.RGBA ();
        color.parse ("#ffffff");
    }

    public override void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        snapshot.append_color (color, bounds);
    }
}
