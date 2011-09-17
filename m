From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Sep 2011 13:33:52 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110917133352.18009.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-17 13:33:51

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Fix for gcc compilation warnings
	
	and put _XOPEN_SOURCE so pthread_mutexattr is properly defined.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/09/02 11:04:12	1.25
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/09/17 13:33:51	1.26
@@ -1,3 +1,6 @@
+#define _GNU_SOURCE
+#define _XOPEN_SOURCE 500  /* pthread */
+
 #include <assert.h>
 #include <pthread.h>
 #include <malloc.h>
@@ -19,6 +22,7 @@
 	} lock;
 } lvmetad_state;
 
+__attribute__ ((format(printf, 1, 2)))
 static void debug(const char *fmt, ...) {
 	va_list ap;
 	va_start(ap, fmt);
@@ -42,8 +46,11 @@
  * allocating memory that we never release. Not good.
  */
 static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
+	pthread_mutex_t *vg;
+	struct dm_config_tree *cft;
+
 	lock_vgs(s);
-	pthread_mutex_t *vg = dm_hash_lookup(s->lock.vg, id);
+	vg = dm_hash_lookup(s->lock.vg, id);
 	if (!vg) {
 		pthread_mutexattr_t rec;
 		pthread_mutexattr_init(&rec);
@@ -53,7 +60,7 @@
 		dm_hash_insert(s->lock.vg, id, vg);
 	}
 	pthread_mutex_lock(vg);
-	struct dm_config_tree *cft = dm_hash_lookup(s->vgs, id);
+	cft = dm_hash_lookup(s->vgs, id);
 	unlock_vgs(s);
 	return cft;
 }
@@ -81,6 +88,7 @@
 		     const char *field, const char *flag, int want) {
 	struct dm_config_value *value = NULL, *pred = NULL;
 	struct dm_config_node *node = dm_config_find_node(parent->child, field);
+	struct dm_config_value *new;
 
 	if (node)
 		value = node->v;
@@ -112,7 +120,7 @@
 			node->parent = parent;
 			parent->child = node;
 		}
-		struct dm_config_value *new = dm_config_create_value(cft);
+		new = dm_config_create_value(cft);
 		new->type = DM_CFG_STRING;
 		new->v.str = flag;
 		new->next = node->v;
@@ -126,10 +134,11 @@
 			    struct dm_config_tree *cft,
 			    struct dm_config_node *vg, int act)
 {
+	struct dm_config_node *pv;
 	int complete = 1;
 
 	lock_pvs(s);
-	struct dm_config_node *pv = pvs(vg);
+	pv = pvs(vg);
 	while (pv) {
 		const char *uuid = dm_config_find_str(pv->child, "id", NULL);
 		int found = uuid ? (dm_hash_lookup(s->pvs, uuid) ? 1 : 0) : 0;
@@ -151,18 +160,21 @@
 
 static response vg_by_uuid(lvmetad_state *s, request r)
 {
+	struct dm_config_tree *cft;
+	struct dm_config_node *metadata;
+	struct dm_config_node *n;
+	response res = { .buffer = NULL };
 	const char *uuid = daemon_request_str(r, "uuid", "NONE");
+
 	debug("vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
-	struct dm_config_tree *cft = lock_vg(s, uuid);
+	cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
 		unlock_vg(s, uuid);
 		return daemon_reply_simple("failed", "reason = %s", "uuid not found", NULL);
 	}
 
-	struct dm_config_node *metadata = cft->root;
+	metadata = cft->root;
 
-	response res = { .buffer = NULL };
-	struct dm_config_node *n;
 	res.cft = dm_config_create(NULL, 0);
 
 	/* The response field */
@@ -249,14 +261,19 @@
  * (anything that might have been retained is copied). */
 static int update_metadata(lvmetad_state *s, const char *_vgid, struct dm_config_node *metadata)
 {
+	struct dm_config_tree *cft;
+	struct dm_config_tree *old;
+	const char *vgid;
 	int retval = 0;
+	int haveseq = -1;
+	int seq;
+
 	lock_vgs(s);
-	struct dm_config_tree *old = dm_hash_lookup(s->vgs, _vgid);
+	old = dm_hash_lookup(s->vgs, _vgid);
 	lock_vg(s, _vgid);
 	unlock_vgs(s);
 
-	int seq = dm_config_find_int(metadata, "metadata/seqno", -1);
-	int haveseq = -1;
+	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
 
 	if (old)
 		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
@@ -278,9 +295,9 @@
 		goto out;
 	}
 
-	struct dm_config_tree *cft = dm_config_create(NULL, 0);
+	cft = dm_config_create(NULL, 0);
 	cft->root = dm_config_clone_node(cft, metadata, 0);
-	const char *vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
+	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
 	if (!vgid)
 		goto out;
@@ -313,6 +330,7 @@
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
+	int complete = 0;
 
 	if (!pvid)
 		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
@@ -338,7 +356,6 @@
 		unlock_pvid_map(s);
 	}
 
-	int complete = 0;
 	if (vgid) {
 		struct dm_config_tree *cft = lock_vg(s, vgid);
 		complete = update_pv_status(s, cft, cft->root, 0);
@@ -374,14 +391,13 @@
 
 static int init(daemon_state *s)
 {
+	pthread_mutexattr_t rec;
 	lvmetad_state *ls = s->private;
 
 	ls->pvs = dm_hash_create(32);
 	ls->vgs = dm_hash_create(32);
 	ls->pvid_map = dm_hash_create(32);
-
 	ls->lock.vg = dm_hash_create(32);
-	pthread_mutexattr_t rec;
 	pthread_mutexattr_init(&rec);
 	pthread_mutexattr_settype(&rec, PTHREAD_MUTEX_RECURSIVE_NP);
 	pthread_mutex_init(&ls->lock.pvs, NULL);
@@ -400,9 +416,10 @@
 
 static int fini(daemon_state *s)
 {
-	debug("fini\n");
 	lvmetad_state *ls = s->private;
 	struct dm_hash_node *n = dm_hash_get_first(ls->vgs);
+
+	debug("fini\n");
 	while (n) {
 		dm_config_destroy(dm_hash_get_data(ls->vgs, n));
 		n = dm_hash_get_next(ls->vgs, n);
@@ -447,6 +464,7 @@
 	s.handler = handler;
 	s.socket_path = "/var/run/lvm/lvmetad.socket";
 	s.pidfile = "/var/run/lvm/lvmetad.pid";
+        s.log_level = 0;
 
 	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
 		switch (opt) {


