From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 30 Nov 2006 13:19:43 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20061130131943.26736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-11-30 13:19:42

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c clvmd.h 

Log message:
	Always compile debug logging into clvmd as it's too useful to
	restrict to just developers.
	-d will switch it on and run the daemon in the foreground

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.509&r2=1.510
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2006/11/30 10:16:47	1.509
+++ LVM2/WHATS_NEW	2006/11/30 13:19:42	1.510
@@ -1,6 +1,7 @@
 Version 2.02.16 -
 ====================================
-  Add startup timeout to RHEL4 clvmd startup script
+  Always compile debug logging into clvmd.
+  Add startup timeout to RHEL4 clvmd startup script.
   Add -T (startup timeout) switch to clvmd.
   Improve lvm_dump.sh robustness.
   Update lvm2create_initrd to support gentoo.
--- LVM2/daemons/clvmd/clvmd.c	2006/11/30 09:44:07	1.30
+++ LVM2/daemons/clvmd/clvmd.c	2006/11/30 13:19:42	1.31
@@ -30,6 +30,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <stddef.h>
+#include <stdarg.h>
 #include <signal.h>
 #include <unistd.h>
 #include <fcntl.h>
@@ -85,6 +86,7 @@
 	int msglen;
 	unsigned short xid;
 };
+static int debug = 0;
 static pthread_t lvm_thread;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
@@ -163,13 +165,27 @@
 }
 
 
+void debuglog(const char *fmt, ...)
+{
+	time_t P;
+	va_list ap;
+
+	if (!debug)
+		return;
+
+	va_start(ap,fmt);
+	time(&P);
+ 	fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime(&P)+4 );
+	vfprintf(stderr, fmt, ap);
+	va_end(ap);
+}
+
 int main(int argc, char *argv[])
 {
 	int local_sock;
 	struct local_client *newfd;
 	struct utsname nodeinfo;
 	signed char opt;
-	int debug = 0;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
 	int start_timeout = 0;
 	sigset_t ss;
--- LVM2/daemons/clvmd/clvmd.h	2005/04/13 13:50:07	1.7
+++ LVM2/daemons/clvmd/clvmd.h	2006/11/30 13:19:42	1.8
@@ -95,11 +95,7 @@
 	} bits;
 };
 
-#ifdef DEBUG
-#define DEBUGLOG(fmt, args...) {time_t P; time(&P); fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime(&P)+4 ); fprintf(stderr, fmt, ## args);}
-#else
-#define DEBUGLOG(fmt, args...)
-#endif
+#define DEBUGLOG(fmt, args...) debuglog(fmt, ## args);
 
 #ifndef max
 #define max(a,b) ((a)>(b)?(a):(b))
@@ -117,6 +113,7 @@
 
 extern void clvmd_cluster_init_completed(void);
 extern void process_message(struct local_client *client, char *buf, int len, char *csid);
+extern void debuglog(const char *fmt, ... );
 
 int sync_lock(const char *resource, int mode, int flags, int *lockid);
 int sync_unlock(const char *resource, int lockid);


