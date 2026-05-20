/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Wrapper around an item if it is currently selected for rendering purposes.
 * TODO: Let's see if the performance holds up
 */
public class Quicknote.SelectedItem : Item {
    public const Gdk.RGBA SELECTION_COLOR = { 0.2f, 0.4f, 0.8f, 0.5f };

    public Item item { get; construct; }

    public Gsk.Transform transform;

    public SelectedItem (Item item, Gsk.Transform transform) {
        Object (item: item);

        /* Can't use transform as gobject property */
        this.transform = transform;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        snapshot.save ();
        snapshot.transform (transform);

        item.snapshot_selected (snapshot);

        snapshot.restore ();
    }

    public override void snapshot_selected (Gtk.Snapshot snapshot) {
        assert_not_reached ();
    }

    public override Graphene.Rect get_bounds () {
        return item.get_bounds ();
    }

    public override bool is_near (Graphene.Point point, float epsilon) {
        var transformed = transform.transform_point (point);
        return item.is_near (transformed, epsilon);
    }

    public override Item copy_transformed (Gsk.Transform transform) {
        assert_not_reached ();
    }

    public Item get_transformed_item () {
        return item.copy_transformed (transform);
    }
}
