/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Penbar : Granite.Bin {
    public const int ICON_SIZE = 32;

    public ToolStore tool_store { get; construct; }

    public Penbar (ToolStore tool_store) {
        Object (tool_store: tool_store);
    }

    construct {
        var factory = new Gtk.SignalListItemFactory ();
        factory.bind.connect (on_bind);

        var list_view = new Gtk.ListView (tool_store.tools, factory);

        child = list_view;

        add_css_class ("osd");
    }

    private static void on_bind (Object obj) {
        var list_item = (Gtk.ListItem) obj;

        var tool = (Tool) list_item.item;

        if (tool is Pen) {
            list_item.child = new PenButton ((Pen) tool);
            return;
        }

        if (tool is Eraser) {
            list_item.child = new Gtk.Image.from_icon_name ("edit-delete") {
                pixel_size = ICON_SIZE,
            };
            return;
        }
    }
}
