From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 30 Sep 2009 12:05:26 -0000
Subject: LVM2/tools vgchange.c
Message-ID: <20090930120526.1971.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-30 12:05:26

Modified files:
	tools          : vgchange.c 

Log message:
	Just a cleanup from previous commit. We don't need pvname local var in _activate_lvs_in_vg anymore...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/tools/vgchange.c	2009/09/29 20:22:35	1.87
+++ LVM2/tools/vgchange.c	2009/09/30 12:05:25	1.88
@@ -56,7 +56,6 @@
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	const char *pvname;
 	int count = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {


