From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 17:37:11 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120215173711.25588.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 17:37:10

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Drop the now-redundant pvid_to_status hash.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 17:30:07	1.36
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 17:37:09	1.37
@@ -12,9 +12,8 @@
 #include "daemon-server.h"
 
 typedef struct {
-	struct dm_hash_table *pvid_to_status;
-	struct dm_hash_table *pvid_to_pvmeta; /* shares locks with status */
-	struct dm_hash_table *device_to_pvid; /* shares locks with status */
+	struct dm_hash_table *pvid_to_pvmeta;
+	struct dm_hash_table *device_to_pvid; /* shares locks with above */
 
 	struct dm_hash_table *vgid_to_metadata;
 	struct dm_hash_table *vgid_to_vgname;
@@ -22,7 +21,7 @@
 	struct dm_hash_table *pvid_to_vgid;
 	struct {
 		struct dm_hash_table *vg;
-		pthread_mutex_t pvid_to_status;
+		pthread_mutex_t pvid_to_pvmeta;
 		pthread_mutex_t vgid_to_metadata;
 		pthread_mutex_t pvid_to_vgid;
 	} lock;
@@ -47,10 +46,10 @@
 	dm_config_write_node(n, &debug_cft_line, NULL);
 }
 
-static void lock_pvid_to_status(lvmetad_state *s) {
-	pthread_mutex_lock(&s->lock.pvid_to_status); }
-static void unlock_pvid_to_status(lvmetad_state *s) {
-	pthread_mutex_unlock(&s->lock.pvid_to_status); }
+static void lock_pvid_to_pvmeta(lvmetad_state *s) {
+	pthread_mutex_lock(&s->lock.pvid_to_pvmeta); }
+static void unlock_pvid_to_pvmeta(lvmetad_state *s) {
+	pthread_mutex_unlock(&s->lock.pvid_to_pvmeta); }
 
 static void lock_vgid_to_metadata(lvmetad_state *s) {
 	pthread_mutex_lock(&s->lock.vgid_to_metadata); }
@@ -234,14 +233,13 @@
 	struct dm_config_node *pv;
 	int complete = 1;
 
-	lock_pvid_to_status(s);
+	lock_pvid_to_pvmeta(s);
 	pv = pvs(vg);
 	while (pv) {
 		const char *uuid = dm_config_find_str(pv->child, "id", NULL);
-		int found = uuid ? (dm_hash_lookup(s->pvid_to_status, uuid) ? 1 : 0) : 0;
+		struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
 		if (act) {
-			set_flag(cft, pv, "status", "MISSING", !found);
-			struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
+			set_flag(cft, pv, "status", "MISSING", !pvmeta);
 			if (pvmeta) {
 				// debug_cft("PV META", pvmeta->root);
 				make_int_node(cft, "device",
@@ -249,16 +247,16 @@
 					      pv, NULL);
 			}
 		}
-		if (!found) {
+		if (!pvmeta) {
 			complete = 0;
 			if (!act) { /* optimisation */
-				unlock_pvid_to_status(s);
+				unlock_pvid_to_pvmeta(s);
 				return complete;
 			}
 		}
 		pv = pv->sib;
 	}
-	unlock_pvid_to_status(s);
+	unlock_pvid_to_pvmeta(s);
 
 	return complete;
 }
@@ -309,7 +307,7 @@
 	res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL);
 	cn_pvs = make_config_node(res.cft, "physical_volumes", NULL, res.cft->root);
 
-	lock_pvid_to_status(s);
+	lock_pvid_to_pvmeta(s);
 
 	struct dm_hash_node *n = dm_hash_get_first(s->pvid_to_pvmeta);
 	while (n) {
@@ -318,7 +316,7 @@
 		n = dm_hash_get_next(s->pvid_to_pvmeta, n);
 	}
 
-	unlock_pvid_to_status(s);
+	unlock_pvid_to_pvmeta(s);
 
 	// debug_cft("PV LIST", res.cft->root);
 
@@ -337,15 +335,15 @@
 
 	struct dm_config_node *pv;
 
-	lock_pvid_to_status(s);
+	lock_pvid_to_pvmeta(s);
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
 	if (!pv) {
-		unlock_pvid_to_status(s);
+		unlock_pvid_to_pvmeta(s);
 		return daemon_reply_simple("failed", "reason = %s", "PV not found", NULL);
 	}
 
 	pv->key = "physical_volume";
-	unlock_pvid_to_status(s);
+	unlock_pvid_to_pvmeta(s);
 
 	// debug_cft("PV LOOKUP", res.cft->root);
 
@@ -584,12 +582,12 @@
 
 	int missing = 1;
 
-	lock_pvid_to_status(s);
+	lock_pvid_to_pvmeta(s);
 
 	while (pv) {
 		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
 		const char *vgid_check = dm_hash_lookup(s->pvid_to_vgid, pvid);
-		if (dm_hash_lookup(s->pvid_to_status, pvid) &&
+		if (dm_hash_lookup(s->pvid_to_pvmeta, pvid) &&
 		    vgid_check && !strcmp(vgid, vgid_check))
 			missing = 0; /* at least one PV is around */
 		pv = pv->sib;
@@ -600,7 +598,7 @@
 		remove_metadata(s, vgid, 0);
 	}
 
-	unlock_pvid_to_status(s);
+	unlock_pvid_to_pvmeta(s);
 
 	return 1;
 }
@@ -701,11 +699,11 @@
 	debug("pv_gone: %s / %lld\n", pvid, device);
 	debug_cft("PV_GONE", r.cft->root);
 
-	lock_pvid_to_status(s);
+	lock_pvid_to_pvmeta(s);
 	if (!pvid && device > 0)
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	if (!pvid) {
-		unlock_pvid_to_status(s);
+		unlock_pvid_to_pvmeta(s);
 		return daemon_reply_simple("failed", "reason = %s", "device not in cache", NULL);
 	}
 
@@ -713,10 +711,9 @@
 
 	struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
-	dm_hash_remove(s->pvid_to_status, pvid);
 	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 	vg_remove_if_missing(s, dm_hash_lookup(s->pvid_to_vgid, pvid));
-	unlock_pvid_to_status(s);
+	unlock_pvid_to_pvmeta(s);
 
 	if (pvmeta) {
 		dm_config_destroy(pvmeta);
@@ -748,9 +745,7 @@
 
 	debug("pv_found %s, vgid = %s, device = %lld\n", pvid, vgid, device);
 
-	lock_pvid_to_status(s);
-	dm_hash_insert(s->pvid_to_status, pvid, (void*)1);
-
+	lock_pvid_to_pvmeta(s);
 	{
 		struct dm_config_tree *cft = dm_config_create();
 		cft->root = dm_config_clone_node(cft, pvmeta, 0);
@@ -758,8 +753,7 @@
 		dm_hash_insert(s->pvid_to_pvmeta, pvid, cft);
 		dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup);
 	}
-
-	unlock_pvid_to_status(s);
+	unlock_pvid_to_pvmeta(s);
 
 	if (metadata) {
 		if (!vgid)
@@ -880,7 +874,6 @@
 	pthread_mutexattr_t rec;
 	lvmetad_state *ls = s->private;
 
-	ls->pvid_to_status = dm_hash_create(32);
 	ls->pvid_to_pvmeta = dm_hash_create(32);
 	ls->device_to_pvid = dm_hash_create(32);
 	ls->vgid_to_metadata = dm_hash_create(32);
@@ -890,7 +883,7 @@
 	ls->lock.vg = dm_hash_create(32);
 	pthread_mutexattr_init(&rec);
 	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
-	pthread_mutex_init(&ls->lock.pvid_to_status, &rec);
+	pthread_mutex_init(&ls->lock.pvid_to_pvmeta, &rec);
 	pthread_mutex_init(&ls->lock.vgid_to_metadata, &rec);
 	pthread_mutex_init(&ls->lock.pvid_to_vgid, NULL);
 
@@ -923,7 +916,6 @@
 	}
 
 	dm_hash_destroy(ls->lock.vg);
-	dm_hash_destroy(ls->pvid_to_status);
 	dm_hash_destroy(ls->pvid_to_pvmeta);
 	dm_hash_destroy(ls->device_to_pvid);
 	dm_hash_destroy(ls->vgid_to_metadata);


