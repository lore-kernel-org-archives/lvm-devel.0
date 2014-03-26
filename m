From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Mar 2014 13:11:58 +0000 (UTC)
Subject: master - cleanup: lvmetad use dm_hash_iterator
Message-ID: <20140326131158.7F6AC60FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fda296da6b992dbafeaeabeacd47fe41f78221e
Commit:        3fda296da6b992dbafeaeabeacd47fe41f78221e
Parent:        dae455f806dfba878e9cfb766f7415ad038d72fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 13:59:13 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 14:11:37 2014 +0100

cleanup: lvmetad use dm_hash_iterator

Simplify code with the use of dm_hash_iterator
---
 daemons/lvmetad/lvmetad-core.c |   42 ++++++++++++---------------------------
 1 files changed, 13 insertions(+), 29 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1858ee2..5b23a56 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -57,27 +57,19 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 {
 	struct dm_hash_node *n = NULL;
 
-	n = dm_hash_get_first(s->vgid_to_metadata);
-	while (n) {
+	dm_hash_iterate(n, s->vgid_to_metadata)
 		dm_config_destroy(dm_hash_get_data(s->vgid_to_metadata, n));
-		n = dm_hash_get_next(s->vgid_to_metadata, n);
-	}
 
-	n = dm_hash_get_first(s->pvid_to_pvmeta);
-	while (n) {
+	dm_hash_iterate(n, s->pvid_to_pvmeta)
 		dm_config_destroy(dm_hash_get_data(s->pvid_to_pvmeta, n));
-		n = dm_hash_get_next(s->pvid_to_pvmeta, n);
-	}
+
 	dm_hash_destroy(s->pvid_to_pvmeta);
 	dm_hash_destroy(s->vgid_to_metadata);
 	dm_hash_destroy(s->vgid_to_vgname);
 	dm_hash_destroy(s->vgname_to_vgid);
 
-	n = dm_hash_get_first(s->device_to_pvid);
-	while (n) {
+	dm_hash_iterate(n, s->device_to_pvid)
 		dm_free(dm_hash_get_data(s->device_to_pvid, n));
-		n = dm_hash_get_next(s->device_to_pvid, n);
-	}
 
 	dm_hash_destroy(s->device_to_pvid);
 	dm_hash_destroy(s->pvid_to_vgid);
@@ -310,8 +302,7 @@ static response pv_list(lvmetad_state *s, request r)
 
 	lock_pvid_to_pvmeta(s);
 
-	for (n = dm_hash_get_first(s->pvid_to_pvmeta); n;
-	     n = dm_hash_get_next(s->pvid_to_pvmeta, n)) {
+	dm_hash_iterate(n, s->pvid_to_pvmeta) {
 		id = dm_hash_get_key(s->pvid_to_pvmeta, n);
 		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
 	}
@@ -397,8 +388,7 @@ static response vg_list(lvmetad_state *s, request r)
 
 	lock_vgid_to_metadata(s);
 
-	n = dm_hash_get_first(s->vgid_to_vgname);
-	while (n) {
+	dm_hash_iterate(n, s->vgid_to_vgname) {
 		id = dm_hash_get_key(s->vgid_to_vgname, n),
 		name = dm_hash_get_data(s->vgid_to_vgname, n);
 
@@ -426,8 +416,6 @@ static response vg_list(lvmetad_state *s, request r)
 		if (!cn_vgs->child)
 			cn_vgs->child = cn;
 		cn_last = cn;
-
-		n = dm_hash_get_next(s->vgid_to_vgname, n);
 	}
 
 	unlock_vgid_to_metadata(s);
@@ -597,8 +585,7 @@ static int update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 		DEBUGLOG(s, "moving PV %s to VG %s", pvid, vgid);
 	}
 
-	for (n = dm_hash_get_first(to_check); n;
-	     n = dm_hash_get_next(to_check, n)) {
+	dm_hash_iterate(n, to_check) {
 		check_vgid = dm_hash_get_key(to_check, n);
 		lock_vg(s, check_vgid);
 		vg_remove_if_missing(s, check_vgid, 0);
@@ -1024,26 +1011,26 @@ static response vg_remove(lvmetad_state *s, request r)
 
 static void _dump_cft(struct buffer *buf, struct dm_hash_table *ht, const char *key_addr)
 {
-	struct dm_hash_node *n = dm_hash_get_first(ht);
-	while (n) {
+	struct dm_hash_node *n;
+
+	dm_hash_iterate(n, ht) {
 		struct dm_config_tree *cft = dm_hash_get_data(ht, n);
 		const char *key_backup = cft->root->key;
 		cft->root->key = dm_config_find_str(cft->root, key_addr, "unknown");
 		(void) dm_config_write_node(cft->root, buffer_line, buf);
 		cft->root->key = key_backup;
-		n = dm_hash_get_next(ht, n);
 	}
 }
 
 static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
 {
 	char *append;
-	struct dm_hash_node *n = dm_hash_get_first(ht);
+	struct dm_hash_node *n;
 
 	buffer_append(buf, name);
 	buffer_append(buf, " {\n");
 
-	while (n) {
+	dm_hash_iterate(n, ht) {
 		const char *key = dm_hash_get_key(ht, n),
 			   *val = dm_hash_get_data(ht, n);
 		buffer_append(buf, "    ");
@@ -1055,7 +1042,6 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 			buffer_append(buf, append);
 		buffer_append(buf, "\n");
 		dm_free(append);
-		n = dm_hash_get_next(ht, n);
 	}
 	buffer_append(buf, "}\n");
 }
@@ -1201,11 +1187,9 @@ static int fini(daemon_state *s)
 	destroy_metadata_hashes(ls);
 
 	/* Destroy the lock hashes now. */
-	n = dm_hash_get_first(ls->lock.vg);
-	while (n) {
+	dm_hash_iterate(n, ls->lock.vg) {
 		pthread_mutex_destroy(dm_hash_get_data(ls->lock.vg, n));
 		free(dm_hash_get_data(ls->lock.vg, n));
-		n = dm_hash_get_next(ls->lock.vg, n);
 	}
 
 	dm_hash_destroy(ls->lock.vg);


