/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

/**
 * Items are the things that make up the document. The most common item
 * are the strokes but there are also PdfPages etc.
 * An item has to be immutable once created. I.e. snapshot should always do the
 * same thing every time it is called.
 * Items only operate in "real" coordinates. I.e. bounds are always the same
 * and the snapshot passed to snapshot is already transformed to "real" coordinates.
 */
public abstract class Paper.Item : Object {
    public abstract void snapshot (Gtk.Snapshot snapshot);
    public abstract void snapshot_selected (Gtk.Snapshot snapshot);
    public abstract Graphene.Rect get_bounds ();
    public abstract bool is_near (Graphene.Point point, float epsilon);
    public abstract Item copy_transformed (Gsk.Transform transform);
}
