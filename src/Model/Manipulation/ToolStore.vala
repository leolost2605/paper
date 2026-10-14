/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.ToolStore : Object {
    public string notebook_id { private get; construct; }

    public ListModel tools { get { return tool_store; } }

    private static Settings settings;
    private static HashTable<string, HashTable<string, Variant>> tools_by_notebook_ids;

    private ListStore tool_store;

    public ToolStore (string notebook_id) {
        Object (notebook_id: notebook_id);
    }

    static construct {
        typeof (Pen).ensure ();
        typeof (Eraser).ensure ();
        typeof (RectangleSelector).ensure ();

        settings = new Settings ("io.github.leolost2605.paper");
        tools_by_notebook_ids = (HashTable<string, HashTable<string, Variant>>) settings.get_value ("tools-by-notebook-ids");
    }

    construct {
        tool_store = new ListStore (typeof (Tool));

        load_last_tools ();

        tool_store.items_changed.connect (on_tools_changed);
    }

    private void load_last_tools () {
        if (!tools_by_notebook_ids.contains (notebook_id)) {
            load_default_tools ();
            return;
        }

        var last_tools = tools_by_notebook_ids[notebook_id];
        foreach (var tool_id in last_tools.get_keys ()) {
            var tool_info = last_tools[tool_id];

            var tool_type_name = (string) tool_info.get_child_value (0);
            var tool_type = Type.from_name (tool_type_name);

            var tool_data = tool_info.get_child_value (1);

            var tool = (Tool) Object.new (tool_type, id: tool_id);

            tool.load (tool_data);

            add_tool (tool);
        }
    }

    private void load_default_tools () {
        create_tool (typeof (Pen));
        create_tool (typeof (Eraser));
        create_tool (typeof (RectangleSelector));
    }

    private void add_tool (Tool tool) {
        tool_store.append (tool);
    }

    private void on_tools_changed () {
        var last_tools = new HashTable<string, Variant> (str_hash, str_equal);

        for (uint i = 0; i < tool_store.n_items; i++) {
            var tool = (Tool) tool_store.get_item (i);
            var tool_data = tool.save ();
            var tool_info = new Variant.tuple ({ tool.get_type ().name (), tool_data });

            last_tools[tool.id] = tool_info;
        }

        tools_by_notebook_ids[notebook_id] = last_tools;
        settings.set_value ("tools-by-notebook-ids", tools_by_notebook_ids);
    }

    public void create_tool (Type tool_type) {
        var tool = (Tool) Object.new (tool_type, id: Uuid.string_random ());
        add_tool (tool);
    }

    public void delete_tool (uint position) {
        tool_store.remove (position);
    }
}
