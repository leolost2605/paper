/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.Penbar : Granite.Bin {
    public const int ICON_SIZE = 32;

    public ToolStore tool_store { get; construct; }
    public ToolSelection tool_selection { get; construct; }

    public Penbar (ToolStore tool_store, ToolSelection tool_selection) {
        Object (tool_store: tool_store, tool_selection: tool_selection);
    }

    construct {
        var factory = new Gtk.SignalListItemFactory ();
        factory.bind.connect (on_bind);

        var list_view = new Gtk.ListView (tool_selection.tools, factory);

        var menu = new Menu ();
        menu.append (_("Pen"), "penbar.add-pen");
        menu.append (_("Eraser"), "penbar.add-eraser");
        menu.append (_("Select"), "penbar.add-select");

        var add_button = new Gtk.MenuButton () {
            icon_name = "list-add-symbolic",
            menu_model = menu,
            direction = RIGHT
        };

        var misc_menu = new Menu ();
        misc_menu.append (_("Go to Origin"), DrawingArea.ACTION_PREFIX + DrawingArea.GO_TO_ORIGIN_ACTION);

        var misc_menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            menu_model = misc_menu,
            direction = RIGHT
        };

        var box = new Granite.Box (VERTICAL);
        box.add_css_class ("content-margin");
        box.append (list_view);
        box.append (new Gtk.Separator (HORIZONTAL));
        box.append (add_button);
        box.append (new Gtk.Separator (HORIZONTAL));
        box.append (misc_menu_button);

        child = box;
        add_css_class ("penbar");
        add_css_class (Granite.CssClass.CARD);

        var add_pen_action = new SimpleAction ("add-pen", null);
        add_pen_action.activate.connect (add_pen);

        var add_eraser_action = new SimpleAction ("add-eraser", null);
        add_eraser_action.activate.connect (add_eraser);

        var add_select_action = new SimpleAction ("add-select", null);
        add_select_action.activate.connect (add_select);

        var delete_tool_action = new SimpleAction ("delete-tool", VariantType.UINT32);
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
            var pen_button = new PenButton ((Pen) tool);
            list_item.bind_property ("position", pen_button, "position", SYNC_CREATE);

            list_item.child = pen_button;
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
        var tool_pos = param.get_uint32 ();
        tool_store.delete_tool (tool_pos);
    }
}
