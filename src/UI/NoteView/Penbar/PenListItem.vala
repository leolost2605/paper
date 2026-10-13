/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/pen-list-item.ui")]
public class Paper.PenListItem : Granite.Bin {
    public Pen pen { get; construct; }

    public uint position { get; set; }

    public PenListItem (Pen pen) {
        typeof (ColorCircle).ensure ();

        Object (pen: pen);
    }

    [GtkCallback]
    private static Variant uint_to_variant (uint value) {
        return new Variant.uint32 (value);
    }
}
