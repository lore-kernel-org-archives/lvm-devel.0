From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Feb 2012 00:18:28 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120229001828.9454.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-29 00:18:27

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Attempt a fix for lvm shell accumulating copies of orphan PVs with each "pvs"
	invocation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.491&r2=1.492

--- LVM2/lib/metadata/metadata.c	2012/02/28 11:12:58	1.491
+++ LVM2/lib/metadata/metadata.c	2012/02/29 00:18:27	1.492
@@ -2775,7 +2775,8 @@
 	return 1;
 }
 
-/* Make orphan PVs look like a VG */
+/* Make orphan PVs look like a VG. FIXME multiple runs will leak memory
+ * allocated to PVs into the orphan VG pool which is now global. */
 static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 					     int warnings,
 					     const char *orphan_vgname)
@@ -2795,6 +2796,8 @@
 		return_NULL;
 
 	vg = fmt->orphan_vg;
+        dm_list_init(&vg->pvs);
+	vg->pv_count = 0;
 
 	baton.warnings = warnings;
 	baton.vg = vg;


