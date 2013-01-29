// CORSIS PortFusion -S[nowfall
// Copyright © 2013  Cetin Sert

#include <stdio.h>          // printf
#include <string.h>         // memset, strlen
#include <stdlib.h>         // atoi
#include <netdb.h>          // addrinfo
#include <sys/socket.h>     // socket, connect, send, recv
#include <unistd.h>         // close, sleep
#include <signal.h>         // signal -- not recommended but works ok for now
#include <errno.h>          // errno

#ifdef  USE_LINUX_SPLICE
#define zeroCopy "True"
#define _GNU_SOURCE
#include <fcntl.h>
#define SPLICE_F_MOVE (0x01)
ssize_t splice(int fd_in,loff_t* off_in,int fd_out,loff_t* off_out, size_t len,unsigned int flags);
#else
#define zeroCopy "False"
#endif

#ifdef  USE_POSIX_THREADS
#include <pthread.h>
#endif

//--------------------------------------------------------------------------------------------CLIENT

#ifndef CHUNK
#define CHUNK (48*1024)
#endif

int sendAll(int s, void* b, ssize_t l) { return send(s, b, l, MSG_NOSIGNAL) != l; } 
int snd (int s, char* m) { sendAll(s, m, strlen(m)); return sendAll(s, "\r\n", strlen("\r\n")); }
int rcv1(int s)          { char m[1]; return recv(s, m, 1, 0); }
int shut(int s)  { /*printf("Close  :.: _ [%i]\n", s);*/shutdown(s, SHUT_RDWR); return close(s); }
int reuse(int s)  { int on = 1; return setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)); }

int at(const char* h, const char* p) // (.@.)
{
  int s = -1, e = -1;
  struct addrinfo hints; memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_socktype = SOCK_STREAM; hints.ai_protocol = IPPROTO_TCP;

  struct addrinfo* as; struct addrinfo* a;
  switch (e = getaddrinfo(h, p, &hints, &as)) {
    case 0:
      for (a = as; a != NULL; a = a->ai_next) {
        s = socket(a->ai_family, a->ai_socktype, a->ai_protocol); if (s < 0) continue;
        e = connect(s, a->ai_addr, a->ai_addrlen);     if (e < 0) shut(s); else break;
      } freeaddrinfo(as); break;
    default: e = abs(e);
  }

  if      (e < 0) { printf("Connec  -  (%s:%s) ", h, p); perror(NULL); }
  else if (e > 0)   printf("Connec  -  (%s:%s) %s\n", h, p, gai_strerror(-e));
  else              printf("Connec  .  [%i] (%s:%s)\n", s, h, p);
  return e < 0 ? e : s;
}

#ifdef BUILD_SERVER
#define MC 128
int lis(const char* h, const char* p) // (@<)
{
  int s = -1, e = -1;
  struct addrinfo hints; memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_socktype = SOCK_STREAM; hints.ai_protocol = IPPROTO_TCP;
  hints.ai_flags    = AI_PASSIVE | AI_NUMERICHOST;

  struct addrinfo* as; struct addrinfo* a;
  switch (e = getaddrinfo(h, p, &hints, &as)) {
    case 0:
      for (a = as; a != NULL; a = a->ai_next) {
        s = socket(a->ai_family, a->ai_socktype, a->ai_protocol);   if (reuse(s) < 0) continue;
        e = bind(s, a->ai_addr, a->ai_addrlen) + listen(s, MC); if (e < 0) shut(s); else break;
      } freeaddrinfo(as); break;
    default: e = abs(e);
  }

  if      (e < 0) { printf("Listen  -  (%s:%s) ", h, p); perror(NULL); }
  else if (e > 0)   printf("Listen  -  (%s:%s) %s\n", h, p, gai_strerror(-e));
  else              printf("Listen  ^  [%i] (%s:%s)\n", s, h, p);
  return e < 0 ? e : s;
}

int acc(int l) { int s = accept(l, NULL, NULL); printf("Accept  .  [%i]\n", s); return s; }
#endif

//--------------------------------------------------------------------------------------------SPLICE

void to(size_t len, int s, int t) // (>-)
{
  int bytes;
#ifdef USE_LINUX_SPLICE
  int rw[2]; if (pipe(rw)) return;
  while ((bytes = splice(s    , NULL, rw[1], NULL, len  , SPLICE_F_MOVE)) > 0)
                  splice(rw[0], NULL, t    , NULL, bytes, SPLICE_F_MOVE);
  close(rw[0]); close(rw[1]);
#else
  char a[len]; while ((bytes = recv(s, a, len, 0)) > 0) if (sendAll(t, a, bytes) < 0) break;
#endif
  shut(t);
}

#ifdef USE_POSIX_THREADS
void* p_to(void* args) { int* lab = (int*) args; to(lab[0], lab[1], lab[2]); return NULL; }

void  flow(int len, int a, int b) /* (>-<) */
{
  printf("Establ  :  [%i] [%i]\n", a, b);
  int lab[3]; lab[0] = len; lab[1] = a; lab[2] = b;
  int lba[3]; lba[0] = len; lba[1] = b; lba[2] = a;
  pthread_t ab, ba;
  pthread_create(&ab, NULL, p_to, (void*) lab); pthread_create(&ba, NULL, p_to, (void*) lba);
  pthread_join  ( ab, NULL                   ); pthread_join  ( ba, NULL                   );
  printf("Termin  :  [%i] [%i]\n", a, b);
}

typedef struct { int l; int a; const char* h; const char* p; } p_flow_args;
void* p_flow(void* args) {
  p_flow_args _ = *((p_flow_args*)args); free(args);
  int b = at(_.h, _.p); if (b > -1) flow(_.l, _.a, b);
                        else        shut(     _.a   );
  return NULL;
}
int forkFlow(int len, int a, const char* h, const char* p) {
  pthread_t t; p_flow_args* _ = malloc(sizeof *_); _->l = len; _->a = a; _->h=h; _->p=p;
  int c = pthread_create(&t, NULL, p_flow, _); pthread_detach(t); return c;
}
#endif

//---------------------------------------------------------------------------------------------TASKS

#define MAC (7)
void dr(const char* a[]) // lp lh - fp fh [ rp                                         _ _ - _ _ [ _
{
  const char* lp = a[1]; const char* lh = a[2];
  const char* fp = a[4]; const char* fh = a[5];
  const char* rp = a[7];
  const char* c  = "Send    .  PeerLink _ _ <%s>\n";
        char  m[64]; sprintf(m, "(:-<-:) %s", rp);
  for (;;) {
         int f = at(fh, fp); if (f < 0) { sleep(1); continue; };
    printf  (c, m);
    if (!snd(f, m) && rcv1(f)) { forkFlow(CHUNK, f, lh, lp); }
    else                             shut(       f        );
  }
}

#ifdef BUILD_SERVER
#undef  MAC
#define MAC (5)
void lf(const char* a[]) // lp ] - rh rp                                                   _ ] - _ _
{
  const char* lp = a[1];
  const char* rh = a[4]; const char* rp = a[5];
  for (;;) {
    int l = lis(NULL, lp); if (l < 0) { sleep(1); continue; }
    for (;;) forkFlow(CHUNK, acc(l), rh, rp);
  }
}
void run(const char* a[]) { if (!strcmp(a[2], "]")) lf(a); else dr(a); }
#define PRODUCT "\x1B[1mCORSIS \x1B[31mPortFusion\x1B[0m\x1B[0m    ( ]S[nowfall 1.0.0 )"
#else
#define run dr
#define PRODUCT "\x1B[1mCORSIS \x1B[31mPortFusion\x1B[0m\x1B[0m    ( -S[nowfall 1.0.0 )"
#endif

//----------------------------------------------------------------------------------------------MAIN

#define KNRM  "\x1B[0m"
#define KBLD  "\x1B[1m"
#define KRED  "\x1B[31m"
#define KBLU  "\x1B[34m"
#define KYEL  "\x1B[33m"

#define KERR KRED
#define KRUN KYEL
#define KINF KBLU

void err() { printf(KERR "Interr  !  SIGPIPE\n" KRUN); }
void ext() { printf(KERR "\b\bInterr  !  Thank you for testing!\n\n\n" KNRM); _exit(0); }

int main(const int c, const char* a[])
{
  setvbuf(stdout, NULL, _IONBF, 0);
  signal(SIGPIPE, err); signal(SIGINT, ext);
  printf("\n\n%s\n", PRODUCT                                         );
  printf(    "%s\n", "(c) 2013 Cetin Sert. All rights reserved." KINF);
  printf("  \n%s - %s - [%s]\n\n", __OS__, __ARCH__, __TIMESTAMP__);
  if (c < MAC + 1) {
    printf(KNRM "%s\n"  , "See usage: http://fusion.corsis.eu");
    printf("%s\n\n", "Available:");
    printf("%s\n", "p h - p h [ p         distributed reverse");
#ifdef BUILD_SERVER
    printf("%s\n", "  p ]     - h p       local       forward");
#endif
    printf("\n\n");
  }
  else { printf("(chunk,%i)\n", CHUNK); printf("(zeroCopy,%s)\n\n", zeroCopy); printf(KRUN); run(a); }
  printf(KNRM);
  return 0;
}
