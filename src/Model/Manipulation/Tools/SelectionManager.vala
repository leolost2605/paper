/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.SelectionManager : Object {
    public enum Operation {
        TRANSLATE,
        RESIZE,
        ROTATE
    }

    public Graphene.Rect item_bounds { get; construct; }

    // Translation and rotation
    private Gsk.Transform current_transform;

    private ResizeNode[] resize_nodes;
    private SelectionFrame selection_frame;

    private Graphene.Point? current_point;
    private Operation? current_operation;
    private ResizeNode.Position? current_resize_node_position;

    public SelectionManager (Graphene.Rect item_bounds) {
        Object (item_bounds: item_bounds);
    }

    construct {
        resize_nodes = {
            new ResizeNode (TOP_LEFT),
            new ResizeNode (TOP_RIGHT),
            new ResizeNode (BOTTOM_LEFT),
            new ResizeNode (BOTTOM_RIGHT)
        };

        selection_frame = new SelectionFrame (item_bounds);

        foreach (var node in resize_nodes) {
            node.update_position (item_bounds);
        }

        current_transform = new Gsk.Transform ();
    }

    public void snapshot (Gtk.Snapshot snapshot) {
        snapshot.save ();
        snapshot.transform (current_transform);

        foreach (var node in resize_nodes) {
            node.snapshot (snapshot);
        }

        selection_frame.snapshot (snapshot);

        snapshot.restore ();
    }

    public bool start (Graphene.Point point) {
        current_point = point;

        /* We need to copy current_transform because invert consumes the transform */
        Gsk.Transform transform = current_transform;
        transform = transform.invert ();
        var transformed_point = transform.transform_point (point);

        foreach (var node in resize_nodes) {
            if (node.contains (transformed_point)) {
                current_operation = RESIZE;
                current_resize_node_position = node.position;
                return true;
            }
        }

        if (selection_frame.contains (transformed_point)) {
            current_operation = TRANSLATE;
            return true;
        }

        return false;
    }

    public void motion (Content content, Graphene.Point point) {
        var delta = Graphene.Point () {
            x = point.x - current_point.x,
            y = point.y - current_point.y
        };

        current_point = point;

        switch (current_operation) {
            case TRANSLATE:
                translate (content, delta);
                break;

            case RESIZE:
                resize (content, current_resize_node_position, delta);
                break;

            case ROTATE:
                break;
        }
    }

    private void translate (Content content, Graphene.Point delta) {
        current_transform = current_transform.translate (delta);

        var transform = new Gsk.Transform ().translate (delta);
        content.transform_selection (transform);
    }

    private void resize (Content content, ResizeNode.Position position, Graphene.Point delta) {
        // TODO: Adjust selection frame scaling and update resize nodes position
    }
}
