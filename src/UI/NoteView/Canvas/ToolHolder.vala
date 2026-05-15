/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.ToolHolder : Granite.Bin {
    public ToolStore tool_store { get; construct; }
    public Viewport viewport { get; construct; }

    public Content? content { get; set; }

    private Tool? current_tool {
        get { return (Tool?) child; }
        set { child = value; }
    }

    public ToolHolder (ToolStore tool_store, Viewport viewport) {
        Object (tool_store: tool_store, viewport: viewport);
    }

    construct {
        notify["content"].connect (update_tool);
        tool_store.tools.selection_changed.connect (update_tool);
        update_tool ();
    }

    private void update_tool () {
        if (current_tool != null) {
            current_tool.deactivate_tool ();
        }

        current_tool = tool_store.active_tool;

        if (current_tool != null && content != null) {
            current_tool.activate_tool (viewport, content);
        }
    }
}
