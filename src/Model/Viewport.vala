/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Viewport : Object {
    public float x { get; set; default = 0.0f; }
    public float y { get; set; default = 0.0f; }
    public float zoom { get; set; default = 1.0f; }

    public Gsk.Transform get_transform () {
        var point = Graphene.Point () {
            x = x,
            y = y
        };
        return new Gsk.Transform ().translate (point).scale (zoom, zoom);
    }
}
