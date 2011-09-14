From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Sep 2011 16:07:08 -0000
Subject: LVM2/libdm libdm-string.c
Message-ID: <20110914160708.3957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-14 16:07:08

Modified files:
	libdm          : libdm-string.c 

Log message:
	Fix memory overwrite
	
	Transfer of build_dm_uuid() function into libdm made uuid_prefix as parameter,
	thus sizeof() was replaced with strlen() and room for '\0' missed.
	
	As it's only fix in current version - no whatsnew.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/libdm/libdm-string.c	2011/09/01 17:58:27	1.16
+++ LVM2/libdm/libdm-string.c	2011/09/14 16:07:07	1.17
@@ -347,7 +347,7 @@
 	if (!layer)
 		layer = "";
 
-	len = strlen(uuid_prefix) + strlen(lvid) + strlen(layer) + 1;
+	len = strlen(uuid_prefix) + strlen(lvid) + strlen(layer) + 2;
 
 	if (!(dmuuid = dm_pool_alloc(mem, len))) {
 		log_error("build_dm_name: Allocation failed for %" PRIsize_t


