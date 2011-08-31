From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Aug 2011 12:39:59 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-config.c ...
Message-ID: <20110831123959.16453.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-31 12:39:58

Modified files:
	libdm          : libdevmapper.h libdm-config.c 
	daemons/common : daemon-server.c daemon-server.h 
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Fix warnings and constness handling in lvmetad-core (adjusting the
	dm_config_find_node to give non-const node pointer, since that better reflects
	the contract of that function).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/libdm/libdevmapper.h	2011/08/30 14:55:15	1.145
+++ LVM2/libdm/libdevmapper.h	2011/08/31 12:39:58	1.146
@@ -1275,7 +1275,7 @@
 time_t dm_config_timestamp(struct dm_config_tree *cft);
 int dm_config_changed(struct dm_config_tree *cft);
 
-const struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
+struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
 float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
--- LVM2/libdm/libdm-config.c	2011/08/30 14:55:16	1.1
+++ LVM2/libdm/libdm-config.c	2011/08/31 12:39:58	1.2
@@ -809,8 +809,8 @@
 /*
  * utility functions
  */
-static const struct dm_config_node *_find_config_node(const void *start,
-						      const char *path)
+static struct dm_config_node *_find_config_node(const void *start,
+						const char *path)
 {
 	const char *e;
 	const struct dm_config_node *cn = start;
@@ -848,15 +848,15 @@
 		path = e;
 	}
 
-	return cn_found;
+	return (struct dm_config_node *) cn_found;
 }
 
-typedef const struct dm_config_node *_node_lookup_fn(const void *start, const char *path);
+typedef struct dm_config_node *_node_lookup_fn(const void *start, const char *path);
 
-static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)
+static struct dm_config_node *_find_first_config_node(const void *start, const char *path)
 {
 	const struct dm_config_tree *cft = start;
-	const struct dm_config_node *cn = NULL;
+	struct dm_config_node *cn = NULL;
 
 	while (cft) {
 		if ((cn = _find_config_node(cft->root, path)))
@@ -973,8 +973,8 @@
  * node-based lookup
  **/
 
-const struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn,
-						 const char *path)
+struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn,
+					   const char *path)
 {
 	return _find_config_node(cn, path);
 }
--- LVM2/daemons/common/daemon-server.c	2011/08/31 12:18:40	1.12
+++ LVM2/daemons/common/daemon-server.c	2011/08/31 12:39:58	1.13
@@ -201,7 +201,7 @@
 	setsid();
 }
 
-response daemon_reply_simple(char *id, ...)
+response daemon_reply_simple(const char *id, ...)
 {
 	va_list ap;
 	va_start(ap, id);
--- LVM2/daemons/common/daemon-server.h	2011/08/30 15:42:57	1.10
+++ LVM2/daemons/common/daemon-server.h	2011/08/31 12:39:58	1.11
@@ -41,7 +41,7 @@
  * Craft a simple reply, without the need to construct a config_tree. See
  * daemon_send_simple in daemon-client.h for the description of the parameters.
  */
-response daemon_reply_simple(char *id, ...);
+response daemon_reply_simple(const char *id, ...);
 
 static inline int daemon_request_int(request r, const char *path, int def) {
 	if (!r.cft)
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/08/30 15:44:01	1.23
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/08/31 12:39:58	1.24
@@ -1,11 +1,11 @@
 #include <assert.h>
 #include <pthread.h>
-
-#include "libdevmapper.h"
 #include <malloc.h>
 #include <stdint.h>
+#include <unistd.h>
 
-#include "../common/daemon-server.h"
+#include "libdevmapper.h"
+#include "daemon-server.h"
 
 typedef struct {
 	struct dm_hash_table *pvs;
@@ -19,29 +19,29 @@
 	} lock;
 } lvmetad_state;
 
-void debug(const char *fmt, ...) {
+static void debug(const char *fmt, ...) {
 	va_list ap;
 	va_start(ap, fmt);
-	fprintf(stderr, "[D %u] ", pthread_self());
+	fprintf(stderr, "[D %lu] ", pthread_self());
 	vfprintf(stderr, fmt, ap);
 	va_end(ap);
 };
 
-void lock_pvs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvs); }
-void unlock_pvs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvs); }
+static void lock_pvs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvs); }
+static void unlock_pvs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvs); }
 
-void lock_vgs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.vgs); }
-void unlock_vgs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.vgs); }
+static void lock_vgs(lvmetad_state *s) { pthread_mutex_lock(&s->lock.vgs); }
+static void unlock_vgs(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.vgs); }
 
-void lock_pvid_map(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvid_map); }
-void unlock_pvid_map(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvid_map); }
+static void lock_pvid_map(lvmetad_state *s) { pthread_mutex_lock(&s->lock.pvid_map); }
+static void unlock_pvid_map(lvmetad_state *s) { pthread_mutex_unlock(&s->lock.pvid_map); }
 
 /*
  * TODO: It may be beneficial to clean up the vg lock hash from time to time,
  * since if we have many "rogue" requests for nonexistent things, we will keep
  * allocating memory that we never release. Not good.
  */
-struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
+static struct dm_config_tree *lock_vg(lvmetad_state *s, const char *id) {
 	lock_vgs(s);
 	pthread_mutex_t *vg = dm_hash_lookup(s->lock.vg, id);
 	if (!vg) {
@@ -58,7 +58,7 @@
 	return cft;
 }
 
-void unlock_vg(lvmetad_state *s, const char *id) {
+static void unlock_vg(lvmetad_state *s, const char *id) {
 	lock_vgs(s); /* someone might be changing the s->lock.vg structure right
 		      * now, so avoid stepping on each other's toes */
 	pthread_mutex_unlock(dm_hash_lookup(s->lock.vg, id));
@@ -78,10 +78,9 @@
  * library here or there.
  */
 static void set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
-		     char *field, const char *flag, int want) {
+		     const char *field, const char *flag, int want) {
 	struct dm_config_value *value = NULL, *pred = NULL;
 	struct dm_config_node *node = dm_config_find_node(parent->child, field);
-	int found = 0;
 
 	if (node)
 		value = node->v;
@@ -184,20 +183,23 @@
 
 static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
 {
+	int r = 0;
+
 	if (a->type > b->type)
 		return 1;
 	if (a->type < b->type)
 		return -1;
 
 	switch (a->type) {
-	case DM_CFG_STRING: return strcmp(a->v.str, b->v.str);
-	case DM_CFG_FLOAT: return a->v.r == b->v.r;
-	case DM_CFG_INT: return a->v.i == b->v.i;
+	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str);
+	case DM_CFG_FLOAT: r = (a->v.r == b->v.r);
+	case DM_CFG_INT: r = (a->v.i == b->v.i);
 	case DM_CFG_EMPTY_ARRAY: return 0;
 	}
 
-	if (a->next && b->next)
-		return compare_value(a->next, b->next);
+	if (r == 0 && a->next && b->next)
+		r = compare_value(a->next, b->next);
+	return r;
 }
 
 static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
@@ -226,7 +228,7 @@
 }
 
 /* You need to be holding the pvid_map lock already to call this. */
-int update_pvid_map(lvmetad_state *s, struct dm_config_tree *vg, const char *vgid)
+static int update_pvid_map(lvmetad_state *s, struct dm_config_tree *vg, const char *vgid)
 {
 	struct dm_config_node *pv = pvs(vg->root);
 
@@ -234,8 +236,8 @@
 		return 0;
 
 	while (pv) {
-		char *pvid = dm_config_find_str(pv->child, "id", NULL);
-		dm_hash_insert(s->pvid_map, pvid, vgid);
+		const char *pvid = dm_config_find_str(pv->child, "id", NULL);
+		dm_hash_insert(s->pvid_map, pvid, (void *) vgid);
 		pv = pv->sib;
 	}
 


