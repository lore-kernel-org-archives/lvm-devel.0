From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jun 2008 19:04:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20080623190435.29920.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-23 19:04:34

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/misc       : util.h 

Log message:
	Add uninitialized_var macro to suppress invalid compiler warnings.
	
	One such warning is seen on fedora9 gcc compiler:
	/metadata.c:1923: warning: 'results' may be used uninitialized in this function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.912&r2=1.913
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2008/06/23 14:54:49	1.912
+++ LVM2/WHATS_NEW	2008/06/23 19:04:34	1.913
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Add uninitialzed_var() macro to suppress invalid compiler warnings.
   Suppress 'sb_offset' compiler warning by using enum for md minor sb version. 
   lvm2_run: Don't return uninitialized "ret" for _memlock_inc or _memlock_dec.
   Avoid link failure when configuring without --enable-cmdlib.
--- LVM2/lib/metadata/metadata.c	2008/06/08 14:18:44	1.181
+++ LVM2/lib/metadata/metadata.c	2008/06/23 19:04:34	1.182
@@ -1920,7 +1920,7 @@
 static int _get_pvs(struct cmd_context *cmd, struct list **pvslist)
 {
 	struct str_list *strl;
-	struct list *results;
+	struct list * uninitialized_var(results);
 	const char *vgname, *vgid;
 	struct list *pvh, *tmp;
 	struct list *vgids;
--- LVM2/lib/misc/util.h	2007/10/03 16:10:04	1.4
+++ LVM2/lib/misc/util.h	2008/06/23 19:04:34	1.5
@@ -25,4 +25,6 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })
 
+#define uninitialized_var(x) x = x
+
 #endif


