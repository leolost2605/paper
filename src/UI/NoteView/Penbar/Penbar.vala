/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/penbar.ui")]
public class Paper.Penbar : Granite.Bin {
    public const int ICON_SIZE = 32;

    public ToolStore tool_store { get; construct; }
    public ToolSelection tool_selection { get; construct; }

    [GtkChild]
    private unowned Gtk.ListView list_view;

    public Penbar (ToolStore tool_store, ToolSelection tool_selection) {
        Object (tool_store: tool_store, tool_selection: tool_selection);
    }

    construct {
        var factory = new Gtk.SignalListItemFactory ();
        factory.bind.connect (on_bind);

        list_view.factory = factory;

        var add_pen_action = new SimpleAction ("add-pen", null);
        add_pen_action.activate.connect (add_pen);

        var add_eraser_action = new SimpleAction ("add-eraser", null);
        add_eraser_action.activate.connect (add_eraser);

        var add_select_action = new SimpleAction ("add-select", null);
        add_select_action.activate.connect (add_select);

        var delete_tool_action = new SimpleAction ("delete-tool", VariantType.STRING);
        delete_tool_action.activate.connect (delete_tool);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (add_pen_action);
        action_group.add_action (add_eraser_action);
        action_group.add_action (add_select_action);
        action_group.add_action (delete_tool_action);
        insert_action_group ("penbar", action_group);
    }

    private static void on_bind (Object obj) {
        var list_item = (Gtk.ListItem) obj;

        var tool = (Tool) list_item.item;

        if (tool is Pen) {
            list_item.child = new PenListItem ((Pen) tool);;
            return;
        }

        if (tool is Eraser) {
            list_item.child = new Gtk.Image.from_icon_name ("edit-delete") {
                pixel_size = ICON_SIZE,
            };
            return;
        }

        if (tool is RectangleSelector) {
            list_item.child = new Gtk.Image.from_icon_name ("edit-select-all-symbolic") {
                pixel_size = ICON_SIZE,
            };
            return;
        }
    }

    private void add_pen () {
        tool_store.create_tool (typeof (Pen));
    }

    private void add_eraser () {
        tool_store.create_tool (typeof (Eraser));
    }

    private void add_select () {
        tool_store.create_tool (typeof (RectangleSelector));
    }

    private void delete_tool (SimpleAction action, Variant? param) {
        var tool_id = param.get_string ();
        tool_store.delete_tool (tool_id);
    }
}
