/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.SelectionManager : Object {
    public enum Operation {
        TRANSLATE,
        RESIZE,
        ROTATE
    }

    public Content content { get; construct; }

    public bool active { get { return !content.selection.is_empty; } }

    private ResizeNode[] resize_nodes;
    private SelectionFrame selection_frame;

    private Graphene.Point? current_point;
    private Operation? current_operation;
    private ResizeNode.Position? current_resize_node_position;

    public SelectionManager (Content content) {
        Object (content: content);
    }

    construct {
        resize_nodes = {
            new ResizeNode (TOP_LEFT),
            new ResizeNode (TOP_RIGHT),
            new ResizeNode (BOTTOM_LEFT),
            new ResizeNode (BOTTOM_RIGHT)
        };

        selection_frame = new SelectionFrame ();
    }

    public void snapshot (Gtk.Snapshot snapshot) {
        selection_frame.snapshot (snapshot);

        foreach (var node in resize_nodes) {
            node.snapshot (snapshot);
        }
    }

    public bool start (Graphene.Point point) {
        /* Update bounds to make sure we select the correct operation */
        update_bounds ();

        current_point = point;

        foreach (var node in resize_nodes) {
            if (node.contains (point)) {
                current_operation = RESIZE;
                current_resize_node_position = node.position;
                return true;
            }
        }

        if (selection_frame.contains (point)) {
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
        var transform = new Gsk.Transform ().translate (delta);
        content.transform_selection (transform);

        update_bounds ();
    }

    private void resize (Content content, ResizeNode.Position position, Graphene.Point delta) {
        // TODO: Adjust selection frame scaling and update resize nodes position
    }

    public void update_bounds () {
        var bounds = content.selection.get_bounds ();

        if (bounds == null) {
            return;
        }

        selection_frame.item_bounds = bounds;

        foreach (var node in resize_nodes) {
            node.update_position (bounds);
        }
    }
}
