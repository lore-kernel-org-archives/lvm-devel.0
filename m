From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:52:01 -0000
Subject: LVM2 ./WHATS_NEW lib/log/log.c
Message-ID: <20111022165201.10791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:52:01

Modified files:
	.              : WHATS_NEW 
	lib/log        : log.c 

Log message:
	Reduce stack size usage in print_log
	
	As the buf2[] and locn[] can't be used at the same time, safe 1 page from
	stack memory.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2167&r2=1.2168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/WHATS_NEW	2011/10/22 16:42:10	1.2167
+++ LVM2/WHATS_NEW	2011/10/22 16:52:00	1.2168
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Remove extra 4kB buffer allocated on stack in print_log().
   Make move_lv_segment non-static function and use dm_list function.
   Pass exclusive LV locks to all nodes in the cluster.
   Improve lvcreate man documentation of the chunksize option.
--- LVM2/lib/log/log.c	2011/08/11 19:21:42	1.65
+++ LVM2/lib/log/log.c	2011/10/22 16:52:00	1.66
@@ -185,7 +185,7 @@
 	       const char *format, ...)
 {
 	va_list ap;
-	char buf[1024], buf2[4096], locn[4096];
+	char buf[1024], locn[4096];
 	int bufused, n;
 	const char *message;
 	const char *trformat;		/* Translated format string */
@@ -221,7 +221,7 @@
 	    (_store_errmsg && (level <= _LOG_ERR)) ||
 	    log_once) {
 		va_start(ap, format);
-		n = vsnprintf(buf2, sizeof(buf2) - 1, trformat, ap);
+		n = vsnprintf(locn, sizeof(locn) - 1, trformat, ap);
 		va_end(ap);
 
 		if (n < 0) {
@@ -230,8 +230,8 @@
 			goto log_it;
 		}
 
-		buf2[sizeof(buf2) - 1] = '\0';
-		message = &buf2[0];
+		locn[sizeof(locn) - 1] = '\0';
+		message = &locn[0];
 	}
 
 /* FIXME Avoid pointless use of message buffer when it'll never be read! */


