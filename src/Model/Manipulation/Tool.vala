/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * TODO: All of the logic here could also be in tool holder. Reevaluate requirements
 * once selector is implemented.
 */
public abstract class Paper.Tool : Object {
    public string id { get; construct; }

    public virtual void activate (Content content) {}
    public virtual void deactivate (Content content) {}

    public abstract RenderFlags start (Content content, float x, float y);
    public abstract RenderFlags motion (Content content, float x, float y, Graphene.Point[] backlog);
    public abstract RenderFlags commit (Content content, float x, float y);
    public virtual void snapshot_transformed (Gtk.Snapshot snapshot) {}
}
