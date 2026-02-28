/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Line : Object {
    public Gee.List<Point> points { get; construct; }

    public Line (Gee.List<Point> points) {
        Object (points: points);
    }

    public bool intersects (Line other) {
        for (int i = 0; i < points.size - 1; i++) {
            var p1 = points[i];
            var p2 = points[i + 1];

            for (int j = 0; j < other.points.size - 1; j++) {
                var p3 = other.points[j];
                var p4 = other.points[j + 1];

                if (lines_intersect (p1, p2, p3, p4)) {
                    return true;
                }
            }
        }

        return false;
    }

    private bool lines_intersect (Point p1, Point p2, Point p3, Point p4) {
        float d = (p2.x - p1.x) * (p4.y - p3.y) - (p2.y - p1.y) * (p4.x - p3.x);
        if (d == 0) {
            return false; // Lines are parallel
        }

        float ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / d;
        float ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / d;

        return ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1;
    }
}
