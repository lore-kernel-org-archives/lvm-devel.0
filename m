From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 16:49:22 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720164922.1432.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 16:49:21

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Can't have a global memory pool in lvmetad (that would constitute an ongoing
	memory leak) => remove it (it's been unused anyway).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 16:46:40	1.11
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 16:49:21	1.12
@@ -7,7 +7,6 @@
 #include "../common/daemon-server.h"
 
 typedef struct {
-	struct dm_pool *mem;
 	struct dm_hash_table *pvs;
 	struct dm_hash_table *vgs;
 	struct dm_hash_table *pvid_to_vgid;
@@ -262,9 +261,8 @@
 
 	ls->pvs = dm_hash_create(32);
 	ls->vgs = dm_hash_create(32);
-	ls->mem = dm_pool_create("lvmetad", 1024); /* whatever */
 	fprintf(stderr, "[D] initialised state: vgs = %p\n", ls->vgs);
-	if (!ls->pvs || !ls->vgs || !ls->mem)
+	if (!ls->pvs || !ls->vgs)
 		return 0;
 
 	/* if (ls->initial_registrations)
@@ -276,7 +274,6 @@
 static int fini(daemon_state *s)
 {
 	lvmetad_state *ls = s->private;
-	dm_pool_destroy(ls->mem);
 	return 1;
 }
 


