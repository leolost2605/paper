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

        var menu = new Menu ();
        menu.append (_("Pen"), "penbar.add-pen");
        menu.append (_("Eraser"), "penbar.add-eraser");
        menu.append (_("Select"), "penbar.add-select");

        var popover = new Gtk.PopoverMenu.from_model (menu);

        var add_button = new Gtk.MenuButton () {
            icon_name = "list-add-symbolic",
            popover = popover,
            direction = RIGHT
        };

        var box = new Granite.Box (VERTICAL);
        box.append (list_view);
        box.append (new Gtk.Separator (HORIZONTAL));
        box.append (add_button);

        child = box;

        add_css_class ("osd");

        var add_pen_action = new SimpleAction ("add-pen", null);
        add_pen_action.activate.connect (add_pen);

        var add_eraser_action = new SimpleAction ("add-eraser", null);
        add_eraser_action.activate.connect (add_eraser);

        var add_select_action = new SimpleAction ("add-select", null);
        add_select_action.activate.connect (add_select);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (add_pen_action);
        action_group.add_action (add_eraser_action);
        action_group.add_action (add_select_action);
        insert_action_group ("penbar", action_group);
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

    private void add_pen () {
        tool_store.add_tool (new Pen ());
    }

    private void add_eraser () {
        tool_store.add_tool (new Eraser ());
    }

    private void add_select () {
        // TODO
    }
}
