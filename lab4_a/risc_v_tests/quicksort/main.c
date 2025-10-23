#ifdef __x86_64__
#include <stdio.h>
#endif

volatile int x;
volatile int y;
volatile int z;

#define QUICK_SORT


// Dangerous, we should add volatile
int* PUT_ADDR = (int *)0xF000fff0;
int* GET_ADDR = (int *)0xF000fff4;
int* FINISH_ADDR = (int *)0xF000fff8;

int getchar() {
  return *GET_ADDR;
}

int putchar(int c) {
  *PUT_ADDR = c;
  return c;
}

int exit2(int c) {
  *FINISH_ADDR = c;
  return c;
}


#ifdef __x86_64__
void print_char(int x) {
    printf("%c", (char) x);
}
void print_string(char* s) {
    printf("%s", s);
}
#ifdef QUICK_SORT
int partition(int* p, int start, int end) {
    int x = p[end]; // threshold
    int j, tmp, i = start - 1;
    for (j = start; j < end; j++) {
        if (p[j] <= x) {
            i++;
            tmp = p[i];
            p[i] = p[j];
            p[j] = tmp;
        }
    }
    tmp = p[i + 1];
    p[i + 1] = p[end];
    p[end] = tmp;
    return i + 1;
}
void quick_sort(int* p, int start, int end) {
    if (start < end) {
        int q = partition(p, start, end);
        quick_sort(p, start, q - 1);
        quick_sort(p, q + 1, end);
    } else {
        int x = exit2(0);
        x = x+1;
    }
}
#endif

void sort(int* p, int start, int end) {
#ifdef QUICK_SORT
    // Quick sort
    quick_sort(p, start, end);
    int x = exit2(0);
#else
    // Bubble sort
    int i, swapped = 1;
    while (swapped != 0) {
        swapped = 0;
        for (i = start; i < end - 1; i++) {
            if (p[i] > p[i + 1]) {
                int tmp = p[i];
                p[i] = p[i + 1];
                p[i + 1] = tmp;
                swapped = 1;
            }
        }
        end--;
    }
#endif
}
int load_arg() {
    return 0;
}
#else /* Risc-v */
void print_char(int x);
// This is much more complicated than it should be to avoid using
// unimplemented half-word and byte loads.
void print_string(char* s) {
    int *s_intptr = (int*) (~3 & (int) s);
    int word = 0;
    int offset = ((int) s) & 3;
    int cur_char = 0xff & (s_intptr[word] >> (offset << 3));
    while (cur_char != '\0') {
        print_char(cur_char);
        if (offset == 3) {
            word++;
            offset = 0;
        } else {
            offset++;
        }
        cur_char = 0xff & (s_intptr[word] >> (offset << 3));
    }
    return;
}
void sort(int* p, int start, int end);
const int LIMIT = 10;
void print_int(int a) {
    int bases[LIMIT];
    bases[0] = 1;
    int i = 0;
    for (i = 1; i < LIMIT; i++) {
        bases[i] = bases[i - 1] * 10;
    }
    i = 0;
    if (a == 0) {
        print_char('0');
    } else if (a == 0x80000000) {
        print_string("-2147483648");
    } else {
        if (a < 0) {
            print_char('-');
            a = -a;
        }
        int j = LIMIT - 1;
        while (a < bases[j]) j--;
        while (j >= 0) {
            int d = 0;
            while (a >= bases[j]) {
                a -= bases[j];
                d ++;
            }
            print_char('0' + d);
            j--;
        }
    }
}
int load_arg();
#endif

int garbage0[20] = {0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF};
int a1[7] = {12, 16, 12, 8, 0, 0, 4};
int garbage1[20] = {0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF};
int a2[6] = {39, 10, -1, -67, 0, -67};
int garbage2[20] = {0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF};
int a3[10] = {2, 4, 0x7FFFFFFF, 0x80000000, 10, 9, 5, 7, 3, -1};
int garbage3[20] = {0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF};
int a4[20] = {
	-64086373, 1651259197, -1727199965, -2145529420, 1174719120, 1194820572, -1056631915, -1648142683, 1031531550, -730913526, 575489485, -1927114178, 1380933512, -1918340173, -1667276094, -552328164, -1720893112, -86470524, -812106727, 177204823,
};
int garbage4[20] = {0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF};
int a5[200] = {
	-1405416422, 1340704403, -1263447598, 280862020, -1974265732, -895145028, 1801631841, 2026682823, -4996149, -1125425578, -1626087852, 1951141062, 571759383, 428910001, 1356438808, -373945275, 1377021994, -1854023183, -1175820194, -647204204,
	1187848653, 1755165719, -569264213, -1206002371, 1141914168, -1168249850, 607892170, -1823531887, -186703935, 153824136, -1031930087, 167490538, -2097078051, 87131750, 1510283006, 1319090772, -1097085391, -1412204971, 1620449927, -706522465,
	-1317641236, 648790481, 1854923222, -554917515, 8590476, 112233599, 758320652, -935753475, -179268044, 911683162, -315528973, 1523076639, -165618189, -861373942, -1397901588, 1808741391, 947906454, 417740520, -1818358590, 1240967452,
	-1822271973, -1979988680, -718567142, -952249097, -1411965908, -1631102252, -1717032888, 1946948795, 932858506, -1028176312, 1811053451, -1680759287, -1394665820, 1023629388, -28870453, -4554968, -310604270, -404983138, 1738547385, -1974077360,
	941947832, 767512782, -1011903349, -1148414226, -1762105236, -1028911315, -221193171, 447506641, 1636466342, -313845698, -2078124899, 851768520, 2009164876, 1552708305, -2124146771, 45127682, -1569474572, 1918078820, 1338192064, 2012913956,
	522712567, 1441736980, 2128634069, -21655236, 510114790, -1219332744, -1524995784, 1767510356, 946566551, -470707443, -1604539454, -522635938, 1688689338, -334311921, -932560326, 1408773789, 1289063418, -1226816631, 947504619, 154067234,
	934727086, -949138063, 787934205, -658222858, 64571426, 277931120, 1714187216, 1120251280, 1445447629, -362255312, -1632101417, 2018207773, 368674369, 1357628240, 1833070789, -403546758, 1873176160, -1168162393, -1743255899, 1819827324,
	462037350, 383171537, -1986424241, -265850252, -1338885583, 1754308229, -8341663, 786600011, 1760234957, -1774446996, 2144536691, 940745005, 1686130730, 290153078, 1076142982, -1376968110, 237838138, 799959248, 1384294368, -1206852459,
	1559513216, 654014314, 1641218906, -1306930001, -324279479, 1628930825, -433731475, -413840882, 1693985654, 378035299, 2073522255, 803496282, 574020038, 1286305936, -962147685, -283341748, -21062784, -1230373575, 2044065471, 842203513,
	-1520624694, 1885615723, -2068808733, -225657225, 1796235340, -1594168627, 1409541962, -1204386200, 2011800783, 165183621, -837744186, 422344375, 611419991, 1764802855, -704767121, 1340208420, 324505539, -1695148136, 602514851, 325481366,
};
int garbage5[20] = {0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF,
                    0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF};
int r1[7] = {0, 0, 4, 8, 12, 12, 16};
int r2[6] = {-67, -67, -1, 0, 10, 39};
int r3[10] = {0x80000000, -1, 2, 3, 4, 5, 7, 9, 10, 0x7FFFFFFF};
int r4[20] = {
    -2145529420, -1927114178, -1918340173, -1727199965, -1720893112, -1667276094, -1648142683, -1056631915, -812106727, -730913526, -552328164, -86470524, -64086373, 177204823, 575489485, 1031531550, 1174719120, 1194820572, 1380933512, 1651259197,
};
int r5[200] = {
	-2124146771, -2097078051, -2078124899, -2068808733, -1986424241, -1979988680, -1974265732, -1974077360, -1854023183, -1823531887, -1822271973, -1818358590, -1774446996, -1762105236, -1743255899, -1717032888, -1695148136, -1680759287, -1632101417, -1631102252,
	-1626087852, -1604539454, -1594168627, -1569474572, -1524995784, -1520624694, -1412204971, -1411965908, -1405416422, -1397901588, -1394665820, -1376968110, -1338885583, -1317641236, -1306930001, -1263447598, -1230373575, -1226816631, -1219332744, -1206852459,
	-1206002371, -1204386200, -1175820194, -1168249850, -1168162393, -1148414226, -1125425578, -1097085391, -1031930087, -1028911315, -1028176312, -1011903349, -962147685, -952249097, -949138063, -935753475, -932560326, -895145028, -861373942, -837744186,
	-718567142, -706522465, -704767121, -658222858, -647204204, -569264213, -554917515, -522635938, -470707443, -433731475, -413840882, -404983138, -403546758, -373945275, -362255312, -334311921, -324279479, -315528973, -313845698, -310604270,
	-283341748, -265850252, -225657225, -221193171, -186703935, -179268044, -165618189, -28870453, -21655236, -21062784, -8341663, -4996149, -4554968, 8590476, 45127682, 64571426, 87131750, 112233599, 153824136, 154067234,
	165183621, 167490538, 237838138, 277931120, 280862020, 290153078, 324505539, 325481366, 368674369, 378035299, 383171537, 417740520, 422344375, 428910001, 447506641, 462037350, 510114790, 522712567, 571759383, 574020038,
	602514851, 607892170, 611419991, 648790481, 654014314, 758320652, 767512782, 786600011, 787934205, 799959248, 803496282, 842203513, 851768520, 911683162, 932858506, 934727086, 940745005, 941947832, 946566551, 947504619,
	947906454, 1023629388, 1076142982, 1120251280, 1141914168, 1187848653, 1240967452, 1286305936, 1289063418, 1319090772, 1338192064, 1340208420, 1340704403, 1356438808, 1357628240, 1377021994, 1384294368, 1408773789, 1409541962, 1441736980,
	1445447629, 1510283006, 1523076639, 1552708305, 1559513216, 1620449927, 1628930825, 1636466342, 1641218906, 1686130730, 1688689338, 1693985654, 1714187216, 1738547385, 1754308229, 1755165719, 1760234957, 1764802855, 1767510356, 1796235340,
	1801631841, 1808741391, 1811053451, 1819827324, 1833070789, 1854923222, 1873176160, 1885615723, 1918078820, 1946948795, 1951141062, 2009164876, 2011800783, 2012913956, 2018207773, 2026682823, 2044065471, 2073522255, 2128634069, 2144536691,
};

const int NUMTESTS = 5;
int main(int argc, char* argv[]) {
    int *p, *t, n, runOnce;
    int arg = load_arg();
    if (arg < 1 || arg > NUMTESTS) {
        arg = 1;
        runOnce = 0;
    } else {
        runOnce = 1;
    }
    do {
        switch (arg) {
            case 1: p = a1; t = r1; n = 7; break;
            case 2: p = a2; t = r2; n = 6; break;
            case 3: p = a3; t = r3; n = 10; break;
            case 4: p = a4; t = r4; n = 20; break;
            case 5: p = a5; t = r5; n = 200; break;
            default: p = a1; t = r1; n = 7; break;
        }

        sort(p, 0, n-1);



        // Evaluation
        int i;
        for (i = 0; i < n; i++) {
            if (p[i] != t[i]) {
#ifdef __x86_64__
                printf("Failed\n");
#else
                print_string("Expected: ");
                for (i = 0; i < n; i++) {
                    print_int(t[i]);
                    print_string(", ");
                }
                print_string("\nObtained: ");
                for (i = 0; i < n; i++) {
                    print_int(p[i]);
                    print_string(", ");
                }
                print_string("\n\nFailed test ");
                print_int(arg);
                print_string("\n\n");
                exit2(1);
#endif
                return -1;
            }
        }
#ifdef __x86_64__
        printf("Passed test %d\n", arg);
#else
        print_string("Passed test ");
        print_int(arg);
        print_string("\n\n");
#endif
        arg ++;
        // End evaluation
    } while (runOnce == 0 && arg <= NUMTESTS);
#ifdef __x86_64__
    if (runOnce == 0) printf("\nPassed all tests\n\n");
#else
    if (runOnce == 0) print_string("Passed all tests\n\n");
        exit2(0);
    return 0;
#endif
}
