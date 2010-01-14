From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:09:43 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100114100943.26015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:09:42

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Move initialization of the 'cmd' member of the struct alloc_handle
	before the first potentional return.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.203&r2=1.204

--- LVM2/lib/metadata/lv_manip.c	2010/01/14 10:08:03	1.203
+++ LVM2/lib/metadata/lv_manip.c	2010/01/14 10:09:42	1.204
@@ -566,11 +566,11 @@
 		return NULL;
 	}
 
+	ah->cmd = cmd;
+
 	if (segtype_is_virtual(segtype))
 		return ah;
 
-	ah->cmd = cmd;
-
 	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
 		log_error("allocation pool creation failed");
 		return NULL;


