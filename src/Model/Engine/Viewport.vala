/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Viewport : Object {
    public float x { get; private set; default = 0.0f; }
    public float y { get; private set; default = 0.0f; }
    public float zoom { get; private set; default = 1.0f; }

    private static Settings settings;
    private static HashTable<string, Variant> viewport_by_state_ids;

    private string? current_state_id;

    static construct {
        settings = new Settings ("io.github.leolost2605.quicknote");
        viewport_by_state_ids = (HashTable<string, Variant>) settings.get_value ("viewport-by-state-ids");
    }

    construct {
        notify.connect (on_notify);
    }

    private void on_notify () {
        if (current_state_id == null) {
            return;
        }

        viewport_by_state_ids[current_state_id] = new double[] { x, y, zoom };
        settings.set_value ("viewport-by-state-ids", viewport_by_state_ids);
    }

    public void load_and_set_state_id (string state_id, Graphene.Size widget_size) {
        current_state_id = state_id;

        if (!viewport_by_state_ids.contains (state_id)) {
            go_to_origin (widget_size);
            return;
        }

        var viewport_state = (double[]) viewport_by_state_ids[state_id];

        freeze_notify ();

        x = (float) viewport_state[0];
        y = (float) viewport_state[1];
        zoom = (float) viewport_state[2];

        thaw_notify ();
    }

    public Gsk.Transform get_transform () {
        var point = Graphene.Point () {
            x = x,
            y = y
        };
        return new Gsk.Transform ().scale (zoom, zoom).translate (point);
    }

    public Graphene.Point widget_to_content_coords (Graphene.Point widget_coords) {
        return get_transform ().invert ().transform_point (widget_coords);
    }

    public Graphene.Point content_to_widget_coords (Graphene.Point content_coords) {
        return get_transform ().transform_point (content_coords);
    }

    public void move_by_widget_coords (float delta_x, float delta_y) {
        x += delta_x / zoom;
        y += delta_y / zoom;
    }

    public void zoom_with_center (float scale, Graphene.Point center) {
        var old_content_coords = widget_to_content_coords (center).to_vec2 ();

        zoom *= scale;

        var new_content_coords = widget_to_content_coords (center).to_vec2 ();

        var diff = new_content_coords.subtract (old_content_coords);

        x += diff.get_x ();
        y += diff.get_y ();
    }

    public void go_to_origin (Graphene.Size widget_size) {
        /* Since we reset zoom to 1.0f we can use widget_size without translation */
        x = widget_size.width / 2.0f;
        y = widget_size.height / 2.0f;
        zoom = 1.0f;
    }
}
