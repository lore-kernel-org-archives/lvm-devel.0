From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jan 2010 10:50:12 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20100108105012.31672.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-08 10:50:12

Modified files:
	lib/metadata   : mirror.c 

Log message:
	orig_status preserves 64bit status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/lib/metadata/mirror.c	2010/01/06 13:27:07	1.103
+++ LVM2/lib/metadata/mirror.c	2010/01/08 10:50:11	1.104
@@ -244,7 +244,7 @@
 {
 	struct str_list *sl;
 	struct lvinfo info;
-	uint32_t orig_status = log_lv->status;
+	uint64_t orig_status = log_lv->status;
 	int was_active = 0;
 
 	if (!activation() && in_sync) {


