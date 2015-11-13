From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Nov 2015 22:56:09 +0000 (UTC)
Subject: master - lvmetad: change the new hash to take data len
Message-ID: <20151113225609.2490160B64@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9295410e98e32636d3bf03ee375c5739bd44b23
Commit:        d9295410e98e32636d3bf03ee375c5739bd44b23
Parent:        e425bce28132e4bad940fae5bfb1499d6a15391d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 13 16:54:22 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 13 16:54:22 2015 -0600

lvmetad: change the new hash to take data len

If the data len is passed into the hash table
and saved there, then the hash table internals
do not need to assume that the data value is
a string at any point.
---
 daemons/lvmetad/lvmetad-core.c |   28 ++++++++++++++--------------
 libdm/.exported_symbols.Base   |    8 ++++----
 libdm/datastruct/hash.c        |   23 +++++++++++++----------
 libdm/libdevmapper.h           |   22 ++++++++--------------
 4 files changed, 39 insertions(+), 42 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index d54dded..0fddd7c 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -736,7 +736,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 		lock_vgid_to_metadata(s);
 		if (name && !uuid)
-			uuid = dm_hash_lookup_str_multival(s->vgname_to_vgid, name, &uuid2);
+			uuid = dm_hash_lookup_multival(s->vgname_to_vgid, name, (void *)&uuid2);
 		else if (uuid && !name)
 			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
 		unlock_vgid_to_metadata(s);
@@ -749,7 +749,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	} else {
 		char *name_lookup = dm_hash_lookup(s->vgid_to_vgname, uuid);
-		char *uuid_lookup = dm_hash_lookup_str_withval(s->vgname_to_vgid, name, uuid);
+		char *uuid_lookup = dm_hash_lookup_withval(s->vgname_to_vgid, name, uuid, strlen(uuid) + 1);
 
 		/* FIXME: comment out these sanity checks when not testing */
 
@@ -920,7 +920,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	name_lookup = dm_hash_lookup(s->vgid_to_vgname, vgid);
 	outdated_pvs_lookup = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
 	if (name_lookup)
-		vgid_lookup = dm_hash_lookup_str_withval(s->vgname_to_vgid, name_lookup, vgid);
+		vgid_lookup = dm_hash_lookup_withval(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
 
 	/* remove hash table mappings */
 
@@ -929,7 +929,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	dm_hash_remove(s->vgid_to_vgname, vgid);
 	dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
 	if (name_lookup)
-		dm_hash_remove_str_withval(s->vgname_to_vgid, name_lookup, vgid);
+		dm_hash_remove_withval(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
 
 	unlock_vgid_to_metadata(s);
 
@@ -1009,8 +1009,8 @@ static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *
 	lock_pvid_to_vgid(s);
 	remove_metadata(s, arg_vgid, 1);
 
-	if ((rem_vgid = dm_hash_lookup_str_withval(s->vgname_to_vgid, arg_name, arg_vgid))) {
-		dm_hash_remove_str_withval(s->vgname_to_vgid, arg_name, arg_vgid);
+	if ((rem_vgid = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
+		dm_hash_remove_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
 		dm_free(rem_vgid);
 	}
 	unlock_pvid_to_vgid(s);
@@ -1077,7 +1077,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	dm_config_destroy(old_meta);
 	old_meta = NULL;
 
-	dm_hash_remove_str_withval(s->vgname_to_vgid, arg_name, old_vgid);
+	dm_hash_remove_withval(s->vgname_to_vgid, arg_name, old_vgid, strlen(old_vgid) + 1);
 	dm_hash_remove(s->vgid_to_vgname, old_vgid);
 	dm_free((char *)old_vgid);
 	old_vgid = NULL;
@@ -1098,7 +1098,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 		goto out;
 	}
 
-	if (!dm_hash_insert_str_multival(s->vgname_to_vgid, arg_name, new_vgid_dup)) {
+	if (!dm_hash_insert_multival(s->vgname_to_vgid, arg_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
 		ERROR(s, "update_metadata_new_vgid out of memory for vgid hash insert for %s %s", arg_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1192,7 +1192,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	old_meta = NULL;
 
 	dm_hash_remove(s->vgid_to_vgname, arg_vgid);
-	dm_hash_remove_str_withval(s->vgname_to_vgid, old_name, arg_vgid);
+	dm_hash_remove_withval(s->vgname_to_vgid, old_name, arg_vgid, strlen(arg_vgid) + 1);
 	dm_free((char *)old_name);
 	old_name = NULL;
 
@@ -1212,7 +1212,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 		goto out;
 	}
 
-	if (!dm_hash_insert_str_multival(s->vgname_to_vgid, new_name, arg_vgid_dup)) {
+	if (!dm_hash_insert_multival(s->vgname_to_vgid, new_name, arg_vgid_dup, strlen(arg_vgid_dup) + 1)) {
 		ERROR(s, "update_metadata_new_name out of memory for vgid hash insert for %s %s", new_name, arg_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1281,7 +1281,7 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 		goto out;
 	}
 
-	if (!dm_hash_insert_str_multival(s->vgname_to_vgid, new_name, new_vgid_dup)) {
+	if (!dm_hash_insert_multival(s->vgname_to_vgid, new_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
 		ERROR(s, "update_metadata_add_new out of memory for vgid hash insert for %s %s", new_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1381,7 +1381,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 */
 	if (pvid && !arg_name_lookup && arg_vgid_lookup &&
 	    strcmp(arg_vgid_lookup, arg_vgid)) {
-		if ((arg_vgid2 = dm_hash_lookup_str_withval(s->vgname_to_vgid, arg_name, arg_vgid))) {
+		if ((arg_vgid2 = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
 			/* This VG already exists in the cache. */
 			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s found VG with same name as %s",
 				 arg_vgid, arg_name, arg_vgid_lookup);
@@ -1402,7 +1402,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	if (!pvid && arg_name_lookup && arg_vgid_lookup &&
 	    !strcmp(arg_name_lookup, arg_name) &&
 	     strcmp(arg_vgid_lookup, arg_vgid)) {
-		if ((arg_vgid2 = dm_hash_lookup_str_withval(s->vgname_to_vgid, arg_name, arg_vgid))) {
+		if ((arg_vgid2 = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
 			/* The first lookup found the another VG with the same name. */
 			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s update VG with same name as %s",
 				 arg_vgid, arg_name, arg_vgid_lookup);
@@ -1442,7 +1442,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		}
 
 		new_vgid = arg_vgid;
-		old_vgid = dm_hash_lookup_str_multival(s->vgname_to_vgid, arg_name, &old_vgid2);
+		old_vgid = dm_hash_lookup_multival(s->vgname_to_vgid, arg_name, (void *)&old_vgid2);
 
 		/*
 		 * FIXME: this ensures that arg_name maps to only one existing
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 30e6a2b..61df67c 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -92,10 +92,10 @@ dm_hash_lookup_binary
 dm_hash_remove
 dm_hash_remove_binary
 dm_hash_wipe
-dm_hash_lookup_str_withval
-dm_hash_lookup_str_multival
-dm_hash_remove_str_withval
-dm_hash_insert_str_multival
+dm_hash_lookup_withval
+dm_hash_lookup_multival
+dm_hash_remove_withval
+dm_hash_insert_multival
 dm_is_dm_major
 dm_is_empty_dir
 dm_lib_exit
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index cf18226..406f5fd 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -18,6 +18,7 @@
 struct dm_hash_node {
 	struct dm_hash_node *next;
 	void *data;
+	unsigned data_len;
 	unsigned keylen;
 	char key[0];
 };
@@ -222,10 +223,8 @@ static struct dm_hash_node **_find_str_withval(struct dm_hash_table *t,
 			continue;
 
 		if (!memcmp(key, (*c)->key, len) && (*c)->data) {
-			char *str = (char *)((*c)->data);
-
-			if (((strlen(str) + 1) == val_len) &&
-			    !memcmp(val, str, val_len))
+			if (((*c)->data_len == val_len) &&
+			    !memcmp(val, (*c)->data, val_len))
 				return c;
 		}
 	}
@@ -233,7 +232,8 @@ static struct dm_hash_node **_find_str_withval(struct dm_hash_table *t,
 	return NULL;
 }
 
-int dm_hash_insert_str_multival(struct dm_hash_table *t, const char *key, const char *val)
+int dm_hash_insert_multival(struct dm_hash_table *t, const char *key,
+			    const void *val, uint32_t val_len)
 {
 	struct dm_hash_node *n;
 	struct dm_hash_node *first;
@@ -245,6 +245,7 @@ int dm_hash_insert_str_multival(struct dm_hash_table *t, const char *key, const
 		return 0;
 
 	n->data = (void *)val;
+	n->data_len = val_len;
 
 	h = _hash(key, len) & (t->num_slots - 1);
 
@@ -264,11 +265,12 @@ int dm_hash_insert_str_multival(struct dm_hash_table *t, const char *key, const
  * Look through multiple entries with the same key for one that has a
  * matching val and return that.  If none have maching val, return NULL.
  */
-void *dm_hash_lookup_str_withval(struct dm_hash_table *t, const char *key, const char *val)
+void *dm_hash_lookup_withval(struct dm_hash_table *t, const char *key,
+			     const void *val, uint32_t val_len)
 {
 	struct dm_hash_node **c;
 
-	c = _find_str_withval(t, key, val, strlen(key) + 1, strlen(val) + 1);
+	c = _find_str_withval(t, key, val, strlen(key) + 1, val_len);
 
 	return (c && *c) ? (*c)->data : 0;
 }
@@ -277,11 +279,12 @@ void *dm_hash_lookup_str_withval(struct dm_hash_table *t, const char *key, const
  * Look through multiple entries with the same key for one that has a
  * matching val and remove that.
  */
-void dm_hash_remove_str_withval(struct dm_hash_table *t, const char *key, const char *val)
+void dm_hash_remove_withval(struct dm_hash_table *t, const char *key,
+			    const void *val, uint32_t val_len)
 {
 	struct dm_hash_node **c;
 
-	c = _find_str_withval(t, key, val, strlen(key) + 1, strlen(val) + 1);
+	c = _find_str_withval(t, key, val, strlen(key) + 1, val_len);
 
 	if (c && *c) {
 		struct dm_hash_node *old = *c;
@@ -306,7 +309,7 @@ void dm_hash_remove_str_withval(struct dm_hash_table *t, const char *key, const
  * If more than two entries have the key, the function looks
  * at only the first two.
  */
-void *dm_hash_lookup_str_multival(struct dm_hash_table *t, const char *key, const char **val2)
+void *dm_hash_lookup_multival(struct dm_hash_table *t, const char *key, const void **val2)
 {
 	struct dm_hash_node **c;
 	struct dm_hash_node **c1 = NULL;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index de2dc3e..a240d0e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1849,20 +1849,14 @@ void *dm_hash_get_data(struct dm_hash_table *t, struct dm_hash_node *n);
 struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t);
 struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n);
 
-/* 
- * Using these requires that string values were inserted.
- * They support the case where multiple values with the
- * same key are inserted.
- *
- * The "withval" variants ensure that an entry matches
- * both the specified key and value.  They are used to
- * return or remove a unique entry by specifiying both
- * the key and the value.
- */
-int dm_hash_insert_str_multival(struct dm_hash_table *t, const char *key, const char *val);
-void *dm_hash_lookup_str_multival(struct dm_hash_table *t, const char *key, const char **val2);
-void *dm_hash_lookup_str_withval(struct dm_hash_table *t, const char *key, const char *val);
-void dm_hash_remove_str_withval(struct dm_hash_table *t, const char *key, const char *val);
+void *dm_hash_lookup_withval(struct dm_hash_table *t, const char *key,
+                             const void *val, uint32_t val_len);
+void dm_hash_remove_withval(struct dm_hash_table *t, const char *key,
+                            const void *val, uint32_t val_len);
+int dm_hash_insert_multival(struct dm_hash_table *t, const char *key,
+                            const void *val, uint32_t val_len);
+void *dm_hash_lookup_multival(struct dm_hash_table *t, const char *key, const void **val2);
+
 
 #define dm_hash_iterate(v, h) \
 	for (v = dm_hash_get_first((h)); v; \


