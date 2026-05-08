/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.PageFormat : Object {
    public bool active { get; construct set; default = false; }

    public float width { get; construct set; }
    public float height { get; construct set; }

    public void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds) {
        if (!active) {
            return;
        }
    }

    public Graphene.Size get_size () {
        return Graphene.Size () {
            width = width,
            height = height
        };
    }
}
