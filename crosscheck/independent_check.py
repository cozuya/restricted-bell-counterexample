#!/usr/bin/env python3
"""Independent audit of the (800,5) restricted-Bell counterexample.

Uses block-type enumeration (not either supplied coefficient recurrence),
formal-series inversion (not the supplied Newton routine), and rational LDL^T
factorization (not either supplied determinant algorithm). It additionally
constructs and checks an integer vector u with u^T H u < 0.

Python 3.9+, standard library only. No source module is imported.
Run: python3 independent_check.py /path/to/certificates/witness.json
"""
from fractions import Fraction
from functools import reduce
from math import factorial, gcd, lcm
from pathlib import Path
import argparse
import hashlib
import json
import time


def top_coefficients(n: int, last: int) -> list[int]:
    # For a block-size j, replacing singletons reduces block count by j-1.
    # Thus a2 + 2*a3 + 3*a4 + 4*a5 = r for coefficient [x^(n-r)].
    falling = [1]
    for t in range(1, min(n, 2 * last) + 1):
        falling.append(falling[-1] * (n - t + 1))
    fac = [factorial(t) for t in range(last + 1)]
    out = []
    for r in range(last + 1):
        total = 0
        for a5 in range(r // 4 + 1):
            for a4 in range((r - 4 * a5) // 3 + 1):
                rem = r - 4 * a5 - 3 * a4
                for a3 in range(rem // 2 + 1):
                    a2 = rem - 2 * a3
                    used = 2*a2 + 3*a3 + 4*a4 + 5*a5
                    if used > n:
                        continue
                    den = (2**a2 * fac[a2] * 6**a3 * fac[a3]
                           * 24**a4 * fac[a4] * 120**a5 * fac[a5])
                    term, remdiv = divmod(falling[used], den)
                    assert remdiv == 0
                    total += term
        out.append(total)
    return out


def series_moments(c: list[int], degree: int) -> list[int]:
    # F(z) = sum (-1)^j c_j z^j = product (1-lambda_i z).
    # Hence -z F'(z)/F(z) = sum_{k>=1} s_k z^k.
    f = [(-1)**i * ci for i, ci in enumerate(c)]
    inverse = [1]
    for k in range(1, len(c)):
        inverse.append(-sum(f[j] * inverse[k-j] for j in range(1, k+1)))
    assert all(sum(f[j] * inverse[k-j] for j in range(k+1)) == 0
               for k in range(1, len(c)))
    return [degree] + [-sum(j * f[j] * inverse[k-j] for j in range(1, k+1))
                       for k in range(1, len(c))]


def ldlt(h: list[list[int]]):
    n = len(h)
    lower = [[Fraction(int(i == j)) for j in range(n)] for i in range(n)]
    diagonal = []
    for j in range(n):
        dj = Fraction(h[j][j]) - sum(lower[j][k]**2 * diagonal[k] for k in range(j))
        assert dj != 0
        diagonal.append(dj)
        for i in range(j+1, n):
            lower[i][j] = (Fraction(h[i][j]) - sum(
                lower[i][k] * lower[j][k] * diagonal[k] for k in range(j))) / dj
    # Independently check every entry of the factorization.
    for i in range(n):
        for j in range(n):
            assert sum(lower[i][k] * diagonal[k] * lower[j][k]
                       for k in range(n)) == h[i][j]
    return lower, diagonal


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('certificate', type=Path)
    parser.add_argument('--out', type=Path, default=Path('independent-certificate.json'))
    args = parser.parse_args()
    started = time.monotonic()
    n, cap, order = 800, 5, 20
    q = (n + cap - 1) // cap
    degree = n - q
    # Basic combinatorial control at n=5: ordinary Bell coefficients in reverse.
    assert top_coefficients(5, 4) == [1, 10, 25, 15, 1]
    c = top_coefficients(n, 2 * order - 2)
    s = series_moments(c, degree)
    h = [[s[i+j] for j in range(order)] for i in range(order)]
    lower, diagonal = ldlt(h)
    determinant = Fraction(1)
    minor_signs = ''
    for d in diagonal:
        determinant *= d
        minor_signs += '+' if determinant > 0 else '-'
    assert determinant.denominator == 1
    determinant = determinant.numerator
    assert all(d > 0 for d in diagonal[:-1]) and diagonal[-1] < 0
    assert -8 * 10**1087 < determinant < -7 * 10**1087

    # u=L^{-T} e_last; then u^T H u = d_last < 0.
    u = [Fraction(0) for _ in range(order)]
    for i in range(order-1, -1, -1):
        u[i] = Fraction(int(i == order-1)) - sum(
            lower[j][i] * u[j] for j in range(i+1, order))
    quadratic = sum(u[i]*h[i][j]*u[j] for i in range(order) for j in range(order))
    assert quadratic == diagonal[-1] and quadratic < 0
    denominator = lcm(*(v.denominator for v in u))
    integer_u = [int(v * denominator) for v in u]
    common = reduce(gcd, integer_u)
    integer_u = [v // common for v in integer_u]
    integer_quadratic = sum(integer_u[i]*h[i][j]*integer_u[j]
                            for i in range(order) for j in range(order))
    assert integer_quadratic < 0

    # Only now read the supplied numerical certificate and compare.
    original = json.loads(args.certificate.read_text())
    assert (original['n'], original['m'], original['q'], original['degree_Q'],
            original['matrix_order']) == (n, cap, q, degree, order)
    assert original['top_coefficients'] == c
    assert original['power_sums_of_negated_roots'] == s
    assert original['leading_principal_minor_signs'] == minor_signs
    assert original['determinant'] == determinant
    out = {
        'n': n, 'm': cap, 'q': q, 'degree_Q': degree, 'matrix_order': order,
        'top_coefficients': c, 'moments': s,
        'coefficient_method': 'Exact block-type enumeration of a2,a3,a4,a5',
        'moment_method': 'Formal-series inversion: -z Fprime(z)/F(z)',
        'determinant_method': 'Exact rational LDL^T, every entry reconstructed',
        'determinant': determinant, 'leading_principal_minor_signs': minor_signs,
        'negative_integer_vector': integer_u,
        'negative_quadratic_form': integer_quadratic,
        'negative_direction_degree': order - 1,
        'source_certificate_sha256': hashlib.sha256(args.certificate.read_bytes()).hexdigest(),
    }
    args.out.write_text(json.dumps(out, indent=2) + '\n')
    print('PASS: independent direct block-type enumeration matches all 39 leading coefficients.')
    print('PASS: formal-series logarithmic derivative matches all 39 moments.')
    print('PASS: exact LDL^T reconstructs every entry of the 20x20 Hankel matrix.')
    print('PASS: determinant agrees with original certificate; signs:', minor_signs)
    print('PASS: -8*10^1087 < determinant < -7*10^1087 < 0.')
    print('PASS: explicit primitive integer vector u satisfies u^T H u < 0.')
    print('Integer vector: length', len(integer_u), '; largest entry digits:',
          max(len(str(abs(v))) for v in integer_u))
    print('Negative quadratic form absolute-value digits:', len(str(abs(integer_quadratic))))
    print('All arithmetic exact. No floating-point root computation used.')
    print('Elapsed: %.3f seconds' % (time.monotonic() - started))
    print('Certificate:', args.out)


if __name__ == '__main__':
    main()
