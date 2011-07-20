From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 18:24:50 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110720182450.14221.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 18:24:49

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Free up allocated memory before exiting, in lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 16:49:21	1.12
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 18:24:49	1.13
@@ -274,6 +274,13 @@
 static int fini(daemon_state *s)
 {
 	lvmetad_state *ls = s->private;
+	struct dm_hash_node *n = dm_hash_get_first(ls->vgs);
+	while (n) {
+		destroy_config_tree(dm_hash_get_data(ls->vgs, n));
+		n = dm_hash_get_next(ls->vgs, n);
+	}
+	dm_hash_destroy(ls->pvs);
+	dm_hash_destroy(ls->vgs);
 	return 1;
 }
 


