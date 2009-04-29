From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Apr 2009 20:14:21 -0000
Subject: LVM2 man/lvcreate.8.in tools/lvcreate.c
Message-ID: <20090429201421.24523.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-29 20:14:21

Modified files:
	man            : lvcreate.8.in 
	tools          : lvcreate.c 

Log message:
	Fixup whitespace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185

--- LVM2/man/lvcreate.8.in	2009/04/29 20:11:46	1.5
+++ LVM2/man/lvcreate.8.in	2009/04/29 20:14:21	1.6
@@ -147,7 +147,7 @@
 .B lvdisplay(8)
 on the snapshot in order to check how much data is allocated to it.
 Note that a small amount of the space you allocate to the snapshot is
-used to track the locations of the chunks of data, so you should 
+used to track the locations of the chunks of data, so you should
 allocate slightly more space than you actually need and monitor the
 rate at which the snapshot data is growing so you can avoid running out
 of space.
--- LVM2/tools/lvcreate.c	2009/04/26 08:12:12	1.184
+++ LVM2/tools/lvcreate.c	2009/04/29 20:14:21	1.185
@@ -563,7 +563,7 @@
 	size_t len;
 	char *vorigin_name;
 	struct logical_volume *lv;
-	
+
 	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
 		log_error("Zero segment type for virtual origin not found");
 		return 0;
@@ -747,7 +747,7 @@
 					  "be mixed.");
 				return 0;
 			}
-	
+
 			if (!lv_info(cmd, org, &info, 0, 0)) {
 				log_error("Check for existence of snapshot "
 					  "origin '%s' failed.", org->name);


