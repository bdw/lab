from __future__ import print_function, division

def cross_vertical(line_d, line_v):
    pt_d1, pt_d2 = line_d
    pt_v1, pt_v2 = line_v
    x_d1, y_d1 = pt_d1
    x_d2, y_d2 = pt_d2

    dy_d = y_d2 - y_d1
    dx_d = x_d2 - x_d1
    if dx_d == 0:
        # parallel (vertical) line
        return None
    slope_d = dy_d / dx_d
    intercept_d = y_d1 - slope_d * x_d1

    x_v, y_v1     = pt_v1
    x_v, y_v2     = pt_v2

    y_meet = slope_d * x_v + intercept_d
    if min(y_v1, y_v2) <= x_v <= max(y_v1, y_v2):
        return x_v, y_meet
    return None

def cross_line(line_a, line_b):
    pt_a1, pt_a2 = line_a
    pt_b1, pt_b2 = line_b
    x_a1, y_a1 = pt_a1
    x_a2, y_a2 = pt_a2
    x_b1, y_b1 = pt_b1
    x_b2, y_b2 = pt_b2

    dy_a = y_a2 - y_a1
    dx_a = x_a2 - x_a1
    dy_b = y_b2 - y_b1
    dx_b = x_b2 - x_b1

    if dx_a == 0:
        return cross_vertical(line_b, line_a)
    if dx_b == 0:
        return cross_vertical(line_a, line_b)

    slope_a = dy_a / dx_a
    slope_b = dy_b / dx_b
    intercept_a = y_a1 - slope_a * x_a1
    intercept_b = y_b1 - slope_b * x_b1
    if slope_a == slope_b:
        # parallel lines, never meet
        return None
    x_meet = (intercept_b - intercept_a) / (slope_a - slope_b)
    y_meet = slope_a * x_meet + intercept_a
    if max(min(x_a1, x_a2), min(x_b1, x_b2)) <= x_meet <= min(max(x_a1, x_a2), max(x_b1, x_b2)):
        return x_meet, y_meet
    return None


if __name__ == '__main__':
    line_a = ((1,1), (3,4))
    line_b = ((1,3), (3,2))
    line_c = ((1,6), (3,5))
    line_v = ((2, 0), (2, 4))

    assert cross_line(line_a, line_b) == (2.0, 2.5)
    assert cross_line(reversed(line_a), line_b) == (2.0, 2.5)
    assert cross_line(line_v, line_b) == (2.0, 2.5)
    assert cross_line(line_b, line_c) is None
    print("done")
