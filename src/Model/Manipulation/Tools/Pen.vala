/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Pen : Quicknote.Tool {
    public Gdk.RGBA color { get; set; default = { 0, 0, 0, 1 }; }
    public float width { get; set; default = 2.0f; }

    private Gee.ArrayList<Point>? points;
    private Gee.ArrayList<Gsk.RenderNode>? render_nodes;

    public override RenderFlags start (Content content, float x, float y) {
        points = new Gee.ArrayList<Point> ();
        points.add (new Point (x, y));

        render_nodes = new Gee.ArrayList<Gsk.RenderNode> ();

        /* This is a hacky workaround for now: In order to support points, i.e. just tapping the screen
         * we immediately add a new point that's offset by just a little to make sure gtk still renders
         * it but it looks just like a point.
         */
        var hacky_point = new Point (x + width / 1000, y + width / 1000);

        points.add (hacky_point);

        var path_builder = new Gsk.PathBuilder ();
        path_builder.move_to (x, y);
        path_builder.line_to (hacky_point.x, hacky_point.y);

        var stroke = new Gsk.Stroke (width);
        stroke.set_line_join (ROUND);
        stroke.set_line_cap (ROUND);

        var snapshot = new Gtk.Snapshot ();
        snapshot.append_stroke (path_builder.to_path (), stroke, color);

        var node = snapshot.to_node ();

        render_nodes.add (node);

        return TOOL_CHANGED;
    }

    public override RenderFlags motion (Content content, float x, float y, Graphene.Point[] backlog) {
        var last_point = points[points.size - 1];

        var path_builder = new Gsk.PathBuilder ();
        path_builder.move_to (last_point.x, last_point.y);

        foreach (var point in backlog) {
            points.add (new Point (point.x, point.y));
            path_builder.line_to (point.x, point.y);
        }

        points.add (new Point (x, y));
        path_builder.line_to (x, y);

        var stroke = new Gsk.Stroke (width);
        stroke.set_line_join (ROUND);
        stroke.set_line_cap (ROUND);

        var snapshot = new Gtk.Snapshot ();
        snapshot.append_stroke (path_builder.to_path (), stroke, color);

        var node = snapshot.to_node ();

        render_nodes.add (node);

        return TOOL_CHANGED;
    }

    public override RenderFlags commit (Content content, float x, float y) {
        points.add (new Point (x, y));

        var stroke = new Stroke (new Line (points.to_array ()), width, color);

        content.add_item (stroke);

        points = null;
        render_nodes = null;

        return TOOL_CHANGED | STROKES_CHANGED;
    }

    public override void snapshot_transformed (Gtk.Snapshot snapshot) {
        if (render_nodes == null) {
            return;
        }

        foreach (var render_node in render_nodes) {
            snapshot.append_node (render_node);
        }
    }
}
