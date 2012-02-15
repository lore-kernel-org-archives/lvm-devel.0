From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2012 13:46:55 -0000
Subject: LVM2/lib/format_pool format_pool.c
Message-ID: <20120215134655.10938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-15 13:46:55

Modified files:
	lib/format_pool: format_pool.c 

Log message:
	Update cut&paste error message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/lib/format_pool/format_pool.c	2012/02/15 01:44:59	1.51
+++ LVM2/lib/format_pool/format_pool.c	2012/02/15 13:46:54	1.52
@@ -315,7 +315,7 @@
 	}
 
 	if (!(fmt->orphan_vg = alloc_vg("pool_orphan", cmd, fmt->orphan_vg_name))) {
-		log_error("Couldn't create lvm1 orphan VG.");
+		log_error("Couldn't create pool orphan VG.");
 		dm_free(fmt);
 		return NULL;
 	}


