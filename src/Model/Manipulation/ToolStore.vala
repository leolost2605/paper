/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.ToolStore : Object {
    public ListModel tools { get { return tool_store; } }

    private ListStore tool_store;

    construct {
        tool_store = new ListStore (typeof (Tool));
    }

    public void add_tool (Tool tool) {
        tool_store.append (tool);
    }
}
