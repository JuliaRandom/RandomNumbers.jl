#include <wmmintrin.h>
#include <stdio.h>

template<unsigned int R>
void ars1xm128i(__m128i *crt,
                __m128i *key,
                __m128i *ret) {

    __m128i kweyl = _mm_set_epi64x(0xBB67AE8584CAA73B, /* sqrt(3) - 1.0 */
                                   0x9E3779B97F4A7C15); /* golden ratio */
    __m128i kk = *key;
    __m128i v = _mm_xor_si128(*crt, kk);
    if (R > 1) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 2) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 3) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 4) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 5) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 6) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 7) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 8) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    if (R > 9) {
        kk = _mm_add_epi64(kk, kweyl);
        v = _mm_aesenc_si128(v, kk);
    }
    kk = _mm_add_epi64(kk, kweyl);
    *ret = _mm_aesenclast_si128(v, kk);
}


extern "C" {
    void ars1xm128i1(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<1>(crt, key, ret);}
    void ars1xm128i2(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<2>(crt, key, ret);}
    void ars1xm128i3(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<3>(crt, key, ret);}
    void ars1xm128i4(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<4>(crt, key, ret);}
    void ars1xm128i5(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<5>(crt, key, ret);}
    void ars1xm128i6(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<6>(crt, key, ret);}
    void ars1xm128i7(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<7>(crt, key, ret);}
    void ars1xm128i8(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<8>(crt, key, ret);}
    void ars1xm128i9(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<9>(crt, key, ret);}
    void ars1xm128i10(__m128i *crt, __m128i *key, __m128i *ret) {ars1xm128i<10>(crt, key, ret);}
}
