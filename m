From: meyering@sourceware.org <meyering@sourceware.org>
Date: Fri, 20 Jul 2007 15:43:27 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.h lib/con ...
Message-ID: <20070720153820.13860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-20 15:38:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.h 
	lib/config     : config.c 
	lib/misc       : lvm-string.h 

Log message:
	Use gcc's printf attribute wherever possible.
	
	* daemons/clvmd/clvmd.h (debuglog): Add __attribute__((printf)).
	* lib/config/config.c (_line_append): Likewise.
	* lib/misc/lvm-string.h (emit_to_buffer): Likewise.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.664&r2=1.665
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2007/07/20 15:26:39	1.664
+++ LVM2/WHATS_NEW	2007/07/20 15:38:19	1.665
@@ -1,4 +1,5 @@
 Version 2.02.28 -
+  Use gcc's printf attribute wherever possible.
   In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
   Introduce is_same_inode macro, now including a comparison of st_dev.
   Don't leak a file descriptor in _lock_file(), when flock fails.
--- LVM2/daemons/clvmd/clvmd.h	2007/05/02 12:22:40	1.9
+++ LVM2/daemons/clvmd/clvmd.h	2007/07/20 15:38:19	1.10
@@ -115,7 +115,8 @@
 extern void clvmd_cluster_init_completed(void);
 extern void process_message(struct local_client *client, const char *buf,
 			    int len, const char *csid);
-extern void debuglog(const char *fmt, ... );
+extern void debuglog(const char *fmt, ... )
+  __attribute__ ((format(printf, 1, 2)));
 
 int sync_lock(const char *resource, int mode, int flags, int *lockid);
 int sync_unlock(const char *resource, int lockid);
--- LVM2/lib/config/config.c	2007/07/20 15:26:39	1.61
+++ LVM2/lib/config/config.c	2007/07/20 15:38:19	1.62
@@ -361,6 +361,8 @@
 }
 
 static int _line_append(struct output_line *outline, const char *fmt, ...)
+  __attribute__ ((format(printf, 2, 3)));
+static int _line_append(struct output_line *outline, const char *fmt, ...)
 {
 	char buf[4096];
 	va_list ap;
--- LVM2/lib/misc/lvm-string.h	2007/04/25 18:24:19	1.14
+++ LVM2/lib/misc/lvm-string.h	2007/07/20 15:38:19	1.15
@@ -23,7 +23,8 @@
 
 struct pool;
 
-int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...);
+int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
+  __attribute__ ((format(printf, 3, 4)));
 
 char *build_dm_name(struct dm_pool *mem, const char *vg,
                     const char *lv, const char *layer);


