From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 21:26:18 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720212618.8327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 21:26:18

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: Robustify update_pv_status and remove an useless lookup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:23:43	1.16
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:26:18	1.17
@@ -149,9 +149,8 @@
 	lock_pvs(s);
 	struct config_node *pv = pvs(vg);
 	while (pv) {
-		const char *uuid = find_config_str(pv->child, "id", "N/A");
-		const char *vgid = find_config_str(vg->root, "metadata/id", "N/A");
-		int found = dm_hash_lookup(s->pvs, uuid) ? 1 : 0;
+		const char *uuid = find_config_str(pv->child, "id", NULL);
+		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
 		// TODO: avoid the override here if MISSING came from the actual
 		// metadata, as opposed from our manipulation...
 		set_flag(vg, pv, "status", "MISSING", !found);


