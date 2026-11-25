/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/library-sidebar.ui")]
public class Paper.LibrarySidebar : Granite.Bin {
    public ListModel items { get; construct; }

    public uint selected { get; set; }
    public Object selected_item { get; set;}

    public Gtk.Expression name_expression { get; set; }
    public Gtk.Expression? icon_name_expression { get; set; }
    public Gtk.Expression? section_name_expression { get; set; }

    [GtkCallback]
    private void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new LibrarySidebarChild ();
    }

    [GtkCallback]
    private void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var child = (LibrarySidebarChild) item.child;
        child.text = evaluate_name_expression (item.item);
        child.icon_name = evaluate_icon_name_expression (item.item);
    }

    private string evaluate_name_expression (Object? obj) {
        if (name_expression == null || name_expression.get_value_type () != typeof (string)) {
            warning ("Invalid name expression set");
            return "Unknown Item";
        }

        Value val = {};
        if (!name_expression.evaluate (obj, ref val)) {
            warning ("Failed to evaluate name expression");
            return "Unknown Item";
        }

        return val.get_string ();
    }

    private string? evaluate_icon_name_expression (Object? obj) {
        if (icon_name_expression == null || icon_name_expression.get_value_type () != typeof (string)) {
            return null;
        }

        Value val = {};
        if (!icon_name_expression.evaluate (obj, ref val)) {
            return null;
        }

        return val.get_string ();
    }
}

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/library-sidebar-child.ui")]
private class Paper.LibrarySidebarChild : Granite.Bin {
    public string text { get; set; }
    public string? icon_name { get; set; }

    [GtkCallback]
    private bool string_to_bool (string? str) {
        return str != null;
    }
}
