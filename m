From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:10:43 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120227101043.16200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:10:43

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Move allocation after check for vgid
	
	so there is no mem leak on this error path.
	Also actually check if the hash exists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/24 00:24:37	1.42
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/27 10:10:43	1.43
@@ -548,7 +548,7 @@
 			       const char *vgid, int nuke_empty)
 {
 	struct dm_config_node *pv = pvs(vg->root);
-	struct dm_hash_table *to_check = dm_hash_create(32);
+	struct dm_hash_table *to_check;
 	struct dm_hash_node *n;
 	const char *pvid;
 	const char *vgid_old;
@@ -556,6 +556,9 @@
 	if (!vgid)
 		return 0;
 
+	if (!(to_check = dm_hash_create(32)))
+		return 0;
+
 	while (pv) {
 		pvid = dm_config_find_str(pv->child, "id", NULL);
 		vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);


