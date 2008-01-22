From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jan 2008 16:02:26 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20080122160226.20755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-22 16:02:26

Modified files:
	lib/metadata   : metadata.c 

Log message:
	suppress compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/lib/metadata/metadata.c	2008/01/22 02:48:52	1.153
+++ LVM2/lib/metadata/metadata.c	2008/01/22 16:02:26	1.154
@@ -1086,7 +1086,7 @@
 /*
  * Determine whether two vgs are compatible for merging.
  */
-int vgs_are_compatible(struct cmd_context *cmd,
+int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to)
 {


