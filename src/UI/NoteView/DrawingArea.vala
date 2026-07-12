/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.DrawingArea : Granite.Bin {
    public const string ACTION_GROUP_PREFIX = "drawing-area";
    public const string ACTION_PREFIX = ACTION_GROUP_PREFIX + ".";
    public const string GO_TO_ORIGIN_ACTION = "go-to-origin";

    public ToolStore tool_store { private get; construct; }
    public ToolSelection tool_selection { private get; construct; }
    public Engine engine { private get; construct; }

    public DrawingArea (ToolStore tool_store, ToolSelection tool_selection, Engine engine) {
        Object (tool_store: tool_store, tool_selection: tool_selection, engine: engine);
    }

    construct {
        var canvas = new Canvas (tool_selection, engine);

        var penbar = new Penbar (tool_store, tool_selection) {
            halign = START,
            valign = CENTER
        };

        var overlay = new Gtk.Overlay () {
            child = canvas,
        };
        overlay.add_overlay (penbar);

        child = overlay;

        var go_to_origin_action = new SimpleAction (GO_TO_ORIGIN_ACTION, null);
        go_to_origin_action.activate.connect (go_to_origin);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (go_to_origin_action);
        insert_action_group (ACTION_GROUP_PREFIX, action_group);
    }

    private void go_to_origin () {
        engine.go_to_origin ();
    }
}
