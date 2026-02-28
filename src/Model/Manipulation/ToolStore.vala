/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.ToolStore : Object {
    public Gtk.SingleSelection tools { get; private set; }

    public Tool? active_tool { get { return tools.selected_item as Tool; } }

    private ListStore tool_store;

    construct {
        tool_store = new ListStore (typeof (Tool));

        tools = new Gtk.SingleSelection (tool_store) {
            autoselect = true,
        };
    }

    public void add_tool (Tool tool) {
        tool_store.append (tool);
    }
}
