From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jan 2011 23:14:05 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20110117231405.22082.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-01-17 23:14:05

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Remove DEBUGLOG from dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/daemons/dmeventd/dmeventd.c	2010/12/20 14:08:46	1.73
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/01/17 23:14:05	1.74
@@ -95,8 +95,6 @@
 
 #define THREAD_STACK_SIZE (300*1024)
 
-#define DEBUGLOG(fmt, args...) _debuglog(fmt, ## args)
-
 int dmeventd_debug = 0;
 static int _foreground = 0;
 static int _restart = 0;
@@ -203,24 +201,6 @@
 static pthread_mutex_t _timeout_mutex = PTHREAD_MUTEX_INITIALIZER;
 static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 
-static void _debuglog(const char *fmt, ...)
-{
-        time_t P;
-        va_list ap;
- 
-        if (!_foreground)
-                return;
- 
-        va_start(ap,fmt);
-
-        time(&P);
-        fprintf(stderr, "dmeventd[%p]: %.15s ", (void *) pthread_self(), ctime(&P)+4 );
-        vfprintf(stderr, fmt, ap);
-	fprintf(stderr, "\n");
-
-        va_end(ap);
-}
-
 /* Allocate/free the status structure for a monitoring thread. */
 static struct thread_status *_alloc_thread_status(struct message_data *data,
 						  struct dso_data *dso_data)
@@ -1621,7 +1601,7 @@
 
 	if (stat(OOM_ADJ_FILE, &st) == -1) {
 		if (errno == ENOENT)
-			DEBUGLOG(OOM_ADJ_FILE " not found");
+			perror(OOM_ADJ_FILE " not found");
 		else
 			perror(OOM_ADJ_FILE ": stat failed");
 		return 1;


