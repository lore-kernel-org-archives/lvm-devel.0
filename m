From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Jul 2011 15:33:05 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110725153305.27045.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-25 15:33:04

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: A couple of TODOs, and fix a few trivial memory leaks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/20 21:33:41	1.19
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/25 15:33:04	1.20
@@ -36,6 +36,11 @@
 void lock_pvid_map(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvid_map); }
 void unlock_pvid_map(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvid_map); }
 
+/*
+ * TODO: It may be beneficial to clean up the vg lock hash from time to time,
+ * since if we have many "rogue" requests for nonexistent things, we will keep
+ * allocating memory that we never release. Not good.
+ */
 struct config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	lock_vgs(s);
 	pthread_mutex_t *vg = dm_hash_lookup(s->lock.vg, id);
@@ -90,6 +95,10 @@
 	return res;
 }
 
+/*
+ * TODO: This set_flag function is pretty generic and might make sense in a
+ * library here or there.
+ */
 static void set_flag(struct config_tree *cft, struct config_node *parent,
 		     char *field, const char *flag, int want) {
 	struct config_value *value = NULL, *pred = NULL;
@@ -337,14 +346,25 @@
 
 static int fini(daemon_state *s)
 {
+	debug("fini\n");
 	lvmetad_state *ls = s->private;
 	struct dm_hash_node *n = dm_hash_get_first(ls->vgs);
 	while (n) {
 		destroy_config_tree(dm_hash_get_data(ls->vgs, n));
 		n = dm_hash_get_next(ls->vgs, n);
 	}
+
+	n = dm_hash_get_first(ls->lock.vg);
+	while (n) {
+		pthread_mutex_destroy(dm_hash_get_data(ls->lock.vg, n));
+		free(dm_hash_get_data(ls->lock.vg, n));
+		n = dm_hash_get_next(ls->lock.vg, n);
+	}
+
+	dm_hash_destroy(ls->lock.vg);
 	dm_hash_destroy(ls->pvs);
 	dm_hash_destroy(ls->vgs);
+	dm_hash_destroy(ls->pvid_map);
 	return 1;
 }
 


