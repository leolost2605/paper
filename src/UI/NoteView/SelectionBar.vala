/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/selection-bar.ui")]
public class Paper.SelectionBar : Granite.Bin {
    public bool should_show { get; set; }
}
