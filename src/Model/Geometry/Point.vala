/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Point : Object {
    public float x { get; construct; }
    public float y { get; construct; }

    public Point (float x, float y) {
        Object (x: x, y: y);
    }
}
