From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jan 2010 13:25:37 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-persistent.c
Message-ID: <20100106132537.20443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-06 13:25:36

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-persistent.c 

Log message:
	Use fixed buffer to prevent stack overflow in persistent filter dump.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1364&r2=1.1365
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2010/01/05 21:32:59	1.1364
+++ LVM2/WHATS_NEW	2010/01/06 13:25:36	1.1365
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Use fixed buffer to prevent stack overflow in persistent filter dump.
   Use snapshot metadata usage to determine if a snapshot is empty.
   Insert missing stack macros to all activate_lv and deactivate_lv callers.
   Insert missing stack macros to all suspend_lv and resume_lv callers.
--- LVM2/lib/filters/filter-persistent.c	2009/12/11 13:16:38	1.39
+++ LVM2/lib/filters/filter-persistent.c	2010/01/06 13:25:36	1.40
@@ -143,7 +143,7 @@
 {
 	void *d;
 	int first = 1;
-	char *buf, *str;
+	char buf[2 * PATH_MAX];
 	struct dm_hash_node *n;
 
 	for (n = dm_hash_get_first(pf->devices); n;
@@ -160,13 +160,8 @@
 			first = 0;
 		}
 
-		str = dm_hash_get_key(pf->devices, n);
-		if (!(buf = alloca(escaped_len(str)))) {
-			log_error("persistent filter device path stack "
-				  "allocation failed");
-			return;
-		}
-		fprintf(fp, "\t\t\"%s\"", escape_double_quotes(buf, str));
+		escape_double_quotes(buf, dm_hash_get_key(pf->devices, n));
+		fprintf(fp, "\t\t\"%s\"", buf);
 	}
 
 	if (!first)


