/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.ToolSelection : Object {
    public ListModel tool_store { private get; construct; }
    public Gtk.SingleSelection tools { get; private set; }

    public Tool? active_tool { get { return tools.selected_item as Tool; } }

    private HashTable<Type, Tool> last_tool_of_type;

    public ToolSelection (ListModel tool_store) {
        Object (tool_store: tool_store);
    }

    construct {
        last_tool_of_type = new HashTable<Type, Tool> (null, null);

        tools = new Gtk.SingleSelection (tool_store) {
            autoselect = true,
        };
        tools.selection_changed.connect (update_last_tool);
    }

    private void update_last_tool () {
        if (active_tool != null) {
            last_tool_of_type[active_tool.get_type ()] = active_tool;
        }
    }

    public void select_last_tool_of_type (Type type) {
        if (!last_tool_of_type.contains (type)) {
            last_tool_of_type[type] = find_first_of_type (type);
        }

        select_tool (last_tool_of_type[type]);
    }

    private Tool? find_first_of_type (Type type) {
        for (uint i = 0; i < tools.n_items; i++) {
            var tool = (Tool) tools.get_item (i);

            if (tool.get_type () == type) {
                return tool;
            }
        }

        return null;
    }

    private void select_tool (Tool tool) {
        for (uint i = 0; i < tools.n_items; i++) {
            var obj = tools.get_item (i);
            if (obj == tool) {
                tools.selected = i;
                break;
            }
        }
    }
}
