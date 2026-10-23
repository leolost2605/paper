/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/pen-list-item.ui")]
public class Paper.PenListItem : Granite.Bin {
    private Pen _pen;
    public Pen pen {
        get { return _pen; }
        set {
            _pen = value;

            value.bind_property ("color", color_button, "rgba", SYNC_CREATE | BIDIRECTIONAL);
            value.bind_property ("width", width_adjustment, "value", SYNC_CREATE | BIDIRECTIONAL);
        }
    }

    [GtkChild]
    private unowned Gtk.ColorDialogButton color_button;
    [GtkChild]
    private unowned Gtk.Adjustment width_adjustment;

    [GtkCallback]
    private Variant? string_to_variant (string? value) {
        if (value == null) {
            return null;
        }

        return new Variant.string (value);
    }
}
