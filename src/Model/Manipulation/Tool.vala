/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * TODO: All of the logic here could also be in tool holder. Reevaluate requirements
 * once selector is implemented.
 */
public abstract class Quicknote.Tool : Object {
    public signal void changed ();

    public string id { get; construct; }

    public abstract void start (Content content, float x, float y);
    public abstract void motion (Content content, float x, float y, Graphene.Point[] backlog);
    public abstract void commit (Content content, float x, float y);
    public virtual void cancel (Content content) {}
    public virtual void snapshot_transformed (Gtk.Snapshot snapshot) {}
}
