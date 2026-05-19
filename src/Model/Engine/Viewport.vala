/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Viewport : Object {
    public float x { get; private set; default = 0.0f; }
    public float y { get; private set; default = 0.0f; }
    public float zoom { get; private set; default = 1.0f; }

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
}
