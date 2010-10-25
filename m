From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:36:58 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20101025133658.2230.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:36:58

Modified files:
	tools          : dmsetup.c 

Log message:
	Fix constness warning
	
	Fix usage of const 'data' pointer and also assign void* directly without
	uneeded cast for C.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/tools/dmsetup.c	2010/10/15 01:10:29	1.146
+++ LVM2/tools/dmsetup.c	2010/10/25 13:36:57	1.147
@@ -2399,7 +2399,7 @@
 			 struct dm_report_field *field, const void *data,
 			 void *private)
 {
-	struct dm_deps *deps = (struct dm_deps *) data;
+	const struct dm_deps *deps = data;
 	int i;
 	char buf[DM_MAX_TYPE_NAME], *repstr;
 


