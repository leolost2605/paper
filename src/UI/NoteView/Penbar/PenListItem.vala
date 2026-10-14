/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/pen-list-item.ui")]
public class Paper.PenListItem : Granite.Bin {
    public Pen pen { get; construct; }

    public PenListItem (Pen pen) {
        typeof (ColorCircle).ensure ();

        Object (pen: pen);
    }

    [GtkCallback]
    private Variant? string_to_variant (string? value) {
        if (value == null) {
            return null;
        }

        return new Variant.string (value);
    }
}
