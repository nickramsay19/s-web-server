#include <stdlib.h>
#include <stdio.h>
extern int listen();
extern void* alloc(int);

extern void* make_res_buf();
//extern int make_res_buf();

int main() {

    //char* s = alloc(255);
    //s[0] = 'Y';
    //s[4095] = 'Y';


    //char* t = make_res_buf();
    //t[0] = 'H';
    //printf("%s\n", t);

    //printf("%d\n", make_res_buf());

    printf("%d\n", listen());

    return 0;
    
    
    /*int x = listen();
    //printf("%d\n", x);
    //return 0;*/
}
