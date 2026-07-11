/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[Flags]
public enum Quicknote.RenderFlags {
    NONE,
    TOOL_CHANGED,
    ZOOM_CHANGED,
    TRANSLATION_CHANGED,
    STROKES_CHANGED,
}
