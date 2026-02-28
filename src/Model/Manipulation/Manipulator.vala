/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Manipulator : Object {
    public ToolStore tool_store { get; construct; }

    public Note note { get; set; }

    public Manipulator (ToolStore tool_store) {
        Object (tool_store: tool_store);
    }

    public void start () {
        tool_store.active_tool?.start (note);
    }

    public void add_point (float x, float y) {
        tool_store.active_tool?.add_point (x, y);
    }

    public void commit () {
        tool_store.active_tool?.commit ();
    }
}
