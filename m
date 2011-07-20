From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 21:27:29 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720212729.9136.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 21:27:29

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: Fix a possible infinite loop in vg_status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:26:18	1.17
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:27:28	1.18
@@ -166,11 +166,8 @@
 
 	while (pv) {
 		const char *uuid = find_config_str(pv->child, "id", NULL);
-		if (!uuid)
-			continue; // FIXME?
-
 		lock_pvs(s);
-		int found = dm_hash_lookup(s->pvs, uuid) ? 1 : 0;
+		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
 		unlock_pvs(s);
 		if (!found) {
 			unlock_vg(s, vgid);


