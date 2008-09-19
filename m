From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 04:28:58 -0000
Subject: LVM2/lib/metadata metadata.h
Message-ID: <20080919042858.11126.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 04:28:58

Modified files:
	lib/metadata   : metadata.h 

Log message:
	Pass struct physical_volume to pe_align.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.180&r2=1.181

--- LVM2/lib/metadata/metadata.h	2008/04/01 22:40:13	1.180
+++ LVM2/lib/metadata/metadata.h	2008/09/19 04:28:58	1.181
@@ -239,7 +239,7 @@
 /*
  * Utility functions
  */
-unsigned long pe_align(void);
+unsigned long pe_align(struct physical_volume *pv);
 int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);


