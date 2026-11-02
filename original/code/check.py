#!/usr/bin/env python3
"""Exact counterexample verifier. Python >= 3.9, standard library only.
Run from the artifact root: python3 code/check.py
No floating-point calculations are used.
"""
from fractions import Fraction
from math import comb, factorial
import json
from pathlib import Path

N, M, ORDER = 800, 5, 20


def coefficient_row(n, m):
    """Generate complete rows by positive block-containing-n recurrence.
    At every step independently check the differential recurrence.
    Return coefficients of B_{n,<=m} in increasing degree order.
    """
    rows = {0: [1]}
    for t in range(1, n + 1):
        a = [0] * (t + 1)
        for j in range(1, min(m, t) + 1):
            weight = comb(t - 1, j - 1)
            for k, v in enumerate(rows[t - j]):
                a[k + 1] += weight * v
        b = [0] * (t + 1)
        for k, v in enumerate(rows[t - 1]):
            b[k + 1] += v
            b[k] += k * v
        if t - 1 >= m:
            weight = comb(t - 1, m)
            for k, v in enumerate(rows[t - 1 - m]):
                b[k + 1] -= weight * v
        assert a == b, ('recurrences disagree', t)
        rows[t] = a
        # Retain the rows needed by both recurrences at the next step.
        if t - 1 - m in rows:
            del rows[t - 1 - m]
    return rows[n]


def egf_row(n, m):
    """Independent check: n!/k! [z^n] g_m(z)^k for every k.
    Multiply g_m by m! so that all polynomial arithmetic is integral.
    """
    scale = factorial(m)
    h = [0] + [scale // factorial(j) for j in range(1, m + 1)]
    power = [1] + [0] * n
    row = [int(n == 0)] + [0] * n
    denominator = 1
    nf = factorial(n)
    for k in range(1, n + 1):
        product = [0] * (n + 1)
        for i, v in enumerate(power):
            if v:
                for j in range(1, min(m, n - i) + 1):
                    product[i + j] += v * h[j]
        power = product
        denominator *= k * scale
        row[k], remainder = divmod(nf * power[n], denominator)
        assert remainder == 0
    return row


def root_power_sums(qpoly, last):
    """s_k = sum(lambda**k), where lambda runs over roots of Q(-x).
    Coefficients qpoly are in increasing order. Newton identities only.
    """
    degree = len(qpoly) - 1
    assert qpoly[-1] == 1 and last <= degree
    c = list(reversed(qpoly))[:last + 1]
    s = [degree]
    for k in range(1, last + 1):
        s.append(sum((-1) ** (i + 1) * c[i] * s[k - i]
                     for i in range(1, k))
                 + (-1) ** (k + 1) * k * c[k])
    return c, s


def bareiss(matrix):
    """Fraction-free elimination, without swaps; exact division asserted.
    Return all leading principal determinants (pivots are nonzero here).
    """
    a = [row[:] for row in matrix]
    old = 1
    minors = []
    for k in range(len(a)):
        pivot = a[k][k]
        assert pivot != 0
        minors.append(pivot)
        for i in range(k + 1, len(a)):
            for j in range(k + 1, len(a)):
                value = pivot * a[i][j] - a[i][k] * a[k][j]
                a[i][j], remainder = divmod(value, old)
                assert remainder == 0
        old = pivot
    return minors


def gaussian_determinant(matrix):
    """Second exact determinant calculation, by rational row operations."""
    a = [[Fraction(v) for v in row] for row in matrix]
    determinant = Fraction(1)
    for k in range(len(a)):
        pivot = a[k][k]
        assert pivot != 0
        determinant *= pivot
        for i in range(k + 1, len(a)):
            multiplier = a[i][k] / pivot
            for j in range(k + 1, len(a)):
                a[i][j] -= multiplier * a[k][j]
            a[i][k] = Fraction(0)
    assert determinant.denominator == 1
    return determinant.numerator


def verify():
    b = coefficient_row(N, M)
    assert b == egf_row(N, M)
    zero_multiplicity = (N + M - 1) // M
    assert b[:zero_multiplicity] == [0] * zero_multiplicity
    qpoly = b[zero_multiplicity:]
    assert all(v > 0 for v in qpoly) and qpoly[-1] == 1
    degree = len(qpoly) - 1
    c, s = root_power_sums(qpoly, 2 * ORDER - 2)
    matrix = [[s[i + j] for j in range(ORDER)] for i in range(ORDER)]
    minors = bareiss(matrix)
    determinant = minors[-1]
    assert all(v > 0 for v in minors[:-1])
    assert -8 * 10**1087 < determinant < -7 * 10**1087 < 0
    assert gaussian_determinant(matrix) == determinant
    certificate = {
        'n': N, 'm': M, 'q': zero_multiplicity, 'degree_Q': degree,
        'matrix_order': ORDER,
        'matrix_definition': 'H[i,j] = s[i+j], 0 <= i,j < 20',
        'coefficient_order': 'c[i] = coefficient of x^(degree_Q-i) in Q',
        'top_coefficients': c,
        'power_sums_of_negated_roots': s,
        'leading_principal_minor_signs': ''.join('+' if v > 0 else '-' for v in minors),
        'determinant': determinant
    }
    root = Path(__file__).resolve().parent.parent
    path = root / 'certificates' / 'witness.json'
    if path.exists():
        assert json.loads(path.read_text()) == certificate
    else:
        path.parent.mkdir(exist_ok=True)
        path.write_text(json.dumps(certificate, indent=2) + '\n')
    print('All 800 rows: counting and differential recurrences agree.')
    print('All 801 final coefficients: independent EGF calculation agrees.')
    print('n =', N, 'm =', M, 'q =', zero_multiplicity, 'degree(Q) =', degree)
    print('Hankel order =', ORDER)
    print('Leading principal minor signs:', certificate['leading_principal_minor_signs'])
    print('det(H) =', determinant)
    print('Both exact determinant calculations agree; det(H) < 0.')
    print('COUNTEREXAMPLE VERIFIED by the moment-matrix obstruction.')
    return certificate


if __name__ == '__main__':
    verify()
