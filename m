From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:59:24 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20111221125924.18306.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:59:23

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Check lv pointer for NULL before derefence.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2207&r2=1.2208
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.254&r2=1.255

--- LVM2/WHATS_NEW	2011/12/21 12:49:00	1.2207
+++ LVM2/WHATS_NEW	2011/12/21 12:59:22	1.2208
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Do not derefence lv pointer in _percent_run() function before NULL check.
   Allow empty strings for description and creation_host config fields.
   Issue deprecation warning when removing last lvm1-format snapshot.
   Reinstate support for snapshot removal with lvm1 format. (2.02.86)
--- LVM2/lib/activate/dev_manager.c	2011/12/21 12:55:22	1.254
+++ LVM2/lib/activate/dev_manager.c	2011/12/21 12:59:22	1.255
@@ -507,7 +507,7 @@
 	uint64_t start, length;
 	char *type = NULL;
 	char *params = NULL;
-	const struct dm_list *segh = &lv->segments;
+	const struct dm_list *segh = lv ? &lv->segments : NULL;
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
 	int first_time = 1;


