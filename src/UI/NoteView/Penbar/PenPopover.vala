/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.PenPopover : Gtk.Popover {
    public Pen pen { get; construct; }

    public uint32 tool_position { get; set; }

    public PenPopover (Pen pen) {
        Object (pen: pen);
    }

    construct {
        var color_dialog = new Gtk.ColorDialog ();
        var color_button = new Gtk.ColorDialogButton (color_dialog);
        pen.bind_property ("color", color_button, "rgba", SYNC_CREATE | BIDIRECTIONAL);

        var width_label = new Granite.HeaderLabel (_("Width"));
        var width_scale = new Gtk.Scale.with_range (HORIZONTAL, 1, 10, 1);
        pen.bind_property ("width", width_scale.adjustment, "value", SYNC_CREATE | BIDIRECTIONAL);

        var width_box = new Granite.Box (VERTICAL, HALF);
        width_box.append (width_label);
        width_box.append (width_scale);

        var delete_button = new Gtk.Button.with_label (_("Remove")) {
            action_name = "penbar.delete-tool",
        };
        delete_button.add_css_class (Granite.CssClass.DESTRUCTIVE);
        bind_property ("tool-position", delete_button, "action-target", SYNC_CREATE, uint_to_variant);

        var box = new Granite.Box (VERTICAL) {
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
        };
        box.append (color_button);
        box.append (width_box);
        box.append (delete_button);
        child = box;
        position = RIGHT;
    }

    private static bool uint_to_variant (Binding binding, Value from_val, ref Value to_val) {
        to_val.set_variant (new Variant.uint32 (from_val.get_uint ()));
        return true;
    }
}
