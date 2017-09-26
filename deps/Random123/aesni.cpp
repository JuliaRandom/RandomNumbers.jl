#include <wmmintrin.h>
#include <stdio.h>

extern "C" {

    static __inline __m128i AES_128_ASSIST (__m128i temp1, __m128i temp2) {
        __m128i temp3;
        temp2 = _mm_shuffle_epi32 (temp2, 0xff);
        temp3 = _mm_slli_si128 (temp1, 0x4);
        temp1 = _mm_xor_si128 (temp1, temp3);
        temp3 = _mm_slli_si128 (temp3, 0x4);
        temp1 = _mm_xor_si128 (temp1, temp3);
        temp3 = _mm_slli_si128 (temp3, 0x4);
        temp1 = _mm_xor_si128 (temp1, temp3);
        temp1 = _mm_xor_si128 (temp1, temp2);
        return temp1;
    }


    void keyinit(__m128i *uk,
            __m128i *ret0,
            __m128i *ret1,
            __m128i *ret2,
            __m128i *ret3,
            __m128i *ret4,
            __m128i *ret5,
            __m128i *ret6,
            __m128i *ret7,
            __m128i *ret8,
            __m128i *ret9,
            __m128i *ret10) {
        __m128i rkey = *uk;
        __m128i tmp2;

        *ret0 = rkey;
        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x1);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret1 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x2);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret2 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x4);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret3 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x8);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret4 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x10);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret5 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x20);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret6 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x40);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret7 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x80);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret8 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x1b);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret9 = rkey;

        tmp2 = _mm_aeskeygenassist_si128(rkey, 0x36);
        rkey = AES_128_ASSIST(rkey, tmp2);
        *ret10 = rkey;
    }

    void aesni1xm128i(__m128i *in,
            __m128i *kk0,
            __m128i *kk1,
            __m128i *kk2,
            __m128i *kk3,
            __m128i *kk4,
            __m128i *kk5,
            __m128i *kk6,
            __m128i *kk7,
            __m128i *kk8,
            __m128i *kk9,
            __m128i *kk10,
            __m128i *ret) {
        __m128i x = _mm_xor_si128(*kk0, *in);
        x = _mm_aesenc_si128(x, *kk1);
        x = _mm_aesenc_si128(x, *kk2);
        x = _mm_aesenc_si128(x, *kk3);
        x = _mm_aesenc_si128(x, *kk4);
        x = _mm_aesenc_si128(x, *kk5);
        x = _mm_aesenc_si128(x, *kk6);
        x = _mm_aesenc_si128(x, *kk7);
        x = _mm_aesenc_si128(x, *kk8);
        x = _mm_aesenc_si128(x, *kk9);
        x = _mm_aesenclast_si128(x, *kk10);
        *ret = x;
    }

}
