/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Tools are objects that manipulate the content. They are always constructed
 * with Object.new (type_name, id); If a new class is implemented the only
 * change is that its type as to be ensured in ToolStore. (Also ofc you probably
 * want a way to add it in the UI).
 */
public abstract class Paper.Tool : Object {
    /**
     * A tool always gets constructed with an ID either an existing one
     * or a new one. The tool itself shouldn't have to deal with the id
     * it's only for identification in the ToolStore.
     */
    public string id { get; construct; }

    /**
     * Should load the existing configuration of the tool.
     * The given variant is guaranteed to be of the type of one previously
     * returned in {@link save}.
     */
    public abstract void load (Variant data);

    /**
     * Should save the current configuration and return a variant with it.
     * The Variant will later be used to load the configuration with {@link load}
     */
    public abstract Variant save ();

    public virtual void activate (Content content) {}
    public virtual void deactivate (Content content) {}

    public abstract RenderFlags start (Content content, float x, float y);
    public abstract RenderFlags motion (Content content, float x, float y, Graphene.Point[] backlog);
    public abstract RenderFlags commit (Content content, float x, float y);
    public virtual void snapshot_transformed (Gtk.Snapshot snapshot) {}
}
