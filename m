From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jul 2008 15:25:10 -0000
Subject: LVM2/tools pvcreate.c pvremove.c
Message-ID: <20080724152510.7361.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-24 15:25:10

Modified files:
	tools          : pvcreate.c pvremove.c 

Log message:
	reinstate lost FIXME
	- only if kernel gives the info, not to be worked out in userspace
	- with lvm.conf option to enable/disable the check

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/tools/pvcreate.c	2008/07/23 19:46:33	1.67
+++ LVM2/tools/pvcreate.c	2008/07/24 15:25:09	1.68
@@ -37,6 +37,8 @@
 	struct device *dev;
 	uint64_t md_superblock;
 
+	/* FIXME Check partition type is LVM unless --force is given */
+
 	/* Is there a pv here already? */
 	/* FIXME Use partial mode here? */
 	pv = pv_read(cmd, name, NULL, NULL, 0);
--- LVM2/tools/pvremove.c	2008/07/23 19:46:33	1.22
+++ LVM2/tools/pvremove.c	2008/07/24 15:25:09	1.23
@@ -26,6 +26,8 @@
 {
 	struct physical_volume *pv;
 
+	/* FIXME Check partition type is LVM unless --force is given */
+
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
 	if (!(pv = pv_read(cmd, name, NULL, NULL, 1))) {


