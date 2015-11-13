From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Nov 2015 21:00:11 +0000 (UTC)
Subject: master - lvmetad: handle duplicate VG names
Message-ID: <20151113210011.CC71E60FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46193f4a59f30d69aa30c9af6aa68f8dec1e81b2
Commit:        46193f4a59f30d69aa30c9af6aa68f8dec1e81b2
Parent:        970a42890905e62c43d20b3b4eb0ec7ece0af11c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 12 10:05:56 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 13 14:56:35 2015 -0600

lvmetad: handle duplicate VG names

New hash table functions are added that allow for
multiple entries with the same key.  Use of the
vgname_to_vgid hash table is converted to these
new functions since there are multiple entries
in vgname_to_vgid that have the same key (vgname).

When multiple VGs with the same name exist, commands
that reference only a VG name will fail saying the
VG could not be found (that error message could be
improved.)  Any command that works with the select
option can access one of the VGs with -S vg_uuid=X.
vgrename is a special case that allows the first VG
name arg to be replaced by a uuid, which also works.

(The existing hash table implementation is not well
suited for handling this case, but it works ok with
the new extensions.  Changing lvmetad to use its own
custom hash tables may be preferable at some point.)
---
 daemons/lvmetad/lvmetad-core.c |   91 +++++++++++++++++++++++----
 libdm/.exported_symbols.Base   |    4 +
 libdm/datastruct/hash.c        |  133 ++++++++++++++++++++++++++++++++++++++++
 libdm/libdevmapper.h           |   15 +++++
 4 files changed, 230 insertions(+), 13 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f7df5fd..d54dded 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -720,9 +720,9 @@ static response vg_lookup(lvmetad_state *s, request r)
 	struct dm_config_node *metadata, *n;
 	struct vg_info *info;
 	response res = { 0 };
-
 	const char *uuid = daemon_request_str(r, "uuid", NULL);
 	const char *name = daemon_request_str(r, "name", NULL);
+	const char *uuid2 = NULL;
 
 	buffer_init( &res.buffer );
 
@@ -736,17 +736,20 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 		lock_vgid_to_metadata(s);
 		if (name && !uuid)
-			uuid = dm_hash_lookup(s->vgname_to_vgid, name);
+			uuid = dm_hash_lookup_str_multival(s->vgname_to_vgid, name, &uuid2);
 		else if (uuid && !name)
 			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
 		unlock_vgid_to_metadata(s);
 
+		if (name && uuid && uuid2)
+			return reply_unknown("Multiple VGs found with same name");
+
 		if (!uuid || !name)
 			return reply_unknown("VG not found");
 
 	} else {
 		char *name_lookup = dm_hash_lookup(s->vgid_to_vgname, uuid);
-		char *uuid_lookup = dm_hash_lookup(s->vgname_to_vgid, name);
+		char *uuid_lookup = dm_hash_lookup_str_withval(s->vgname_to_vgid, name, uuid);
 
 		/* FIXME: comment out these sanity checks when not testing */
 
@@ -917,7 +920,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	name_lookup = dm_hash_lookup(s->vgid_to_vgname, vgid);
 	outdated_pvs_lookup = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
 	if (name_lookup)
-		vgid_lookup = dm_hash_lookup(s->vgname_to_vgid, name_lookup);
+		vgid_lookup = dm_hash_lookup_str_withval(s->vgname_to_vgid, name_lookup, vgid);
 
 	/* remove hash table mappings */
 
@@ -926,7 +929,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	dm_hash_remove(s->vgid_to_vgname, vgid);
 	dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
 	if (name_lookup)
-		dm_hash_remove(s->vgname_to_vgid, name_lookup);
+		dm_hash_remove_str_withval(s->vgname_to_vgid, name_lookup, vgid);
 
 	unlock_vgid_to_metadata(s);
 
@@ -1006,8 +1009,8 @@ static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *
 	lock_pvid_to_vgid(s);
 	remove_metadata(s, arg_vgid, 1);
 
-	if ((rem_vgid = dm_hash_lookup(s->vgname_to_vgid, arg_name))) {
-		dm_hash_remove(s->vgname_to_vgid, arg_name);
+	if ((rem_vgid = dm_hash_lookup_str_withval(s->vgname_to_vgid, arg_name, arg_vgid))) {
+		dm_hash_remove_str_withval(s->vgname_to_vgid, arg_name, arg_vgid);
 		dm_free(rem_vgid);
 	}
 	unlock_pvid_to_vgid(s);
@@ -1074,7 +1077,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	dm_config_destroy(old_meta);
 	old_meta = NULL;
 
-	dm_hash_remove(s->vgname_to_vgid, arg_name);
+	dm_hash_remove_str_withval(s->vgname_to_vgid, arg_name, old_vgid);
 	dm_hash_remove(s->vgid_to_vgname, old_vgid);
 	dm_free((char *)old_vgid);
 	old_vgid = NULL;
@@ -1095,7 +1098,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 		goto out;
 	}
 
-	if (!dm_hash_insert(s->vgname_to_vgid, arg_name, new_vgid_dup)) {
+	if (!dm_hash_insert_str_multival(s->vgname_to_vgid, arg_name, new_vgid_dup)) {
 		ERROR(s, "update_metadata_new_vgid out of memory for vgid hash insert for %s %s", arg_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1189,7 +1192,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	old_meta = NULL;
 
 	dm_hash_remove(s->vgid_to_vgname, arg_vgid);
-	dm_hash_remove(s->vgname_to_vgid, old_name);
+	dm_hash_remove_str_withval(s->vgname_to_vgid, old_name, arg_vgid);
 	dm_free((char *)old_name);
 	old_name = NULL;
 
@@ -1209,7 +1212,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 		goto out;
 	}
 
-	if (!dm_hash_insert(s->vgname_to_vgid, new_name, arg_vgid_dup)) {
+	if (!dm_hash_insert_str_multival(s->vgname_to_vgid, new_name, arg_vgid_dup)) {
 		ERROR(s, "update_metadata_new_name out of memory for vgid hash insert for %s %s", new_name, arg_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1278,7 +1281,7 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 		goto out;
 	}
 
-	if (!dm_hash_insert(s->vgname_to_vgid, new_name, new_vgid_dup)) {
+	if (!dm_hash_insert_str_multival(s->vgname_to_vgid, new_name, new_vgid_dup)) {
 		ERROR(s, "update_metadata_add_new out of memory for vgid hash insert for %s %s", new_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1339,6 +1342,8 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	const char *new_name = NULL;
 	const char *old_vgid = NULL;
 	const char *new_vgid = NULL;
+	const char *arg_vgid2 = NULL;
+	const char *old_vgid2 = NULL;
 	const char *new_metadata_vgid;
 	int old_seq = -1;
 	int new_seq = -1;
@@ -1368,6 +1373,46 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	arg_vgid_lookup = dm_hash_lookup(s->vgname_to_vgid, arg_name);
 
 	/*
+	 * A new PV has been found with a VG that:
+	 * has a vgid we don't know about (null arg_name_lookup),
+	 * has a name we do know about (non-null arg_vgid_lookup).
+	 * This happens when there are two different VGs with the
+	 * same name.
+	 */
+	if (pvid && !arg_name_lookup && arg_vgid_lookup &&
+	    strcmp(arg_vgid_lookup, arg_vgid)) {
+		if ((arg_vgid2 = dm_hash_lookup_str_withval(s->vgname_to_vgid, arg_name, arg_vgid))) {
+			/* This VG already exists in the cache. */
+			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s found VG with same name as %s",
+				 arg_vgid, arg_name, arg_vgid_lookup);
+			arg_vgid_lookup = arg_vgid2;
+		} else {
+			/* This VG doesn't exist in cache yet. */
+			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s found VG with same name as %s",
+				 arg_vgid, arg_name, arg_vgid_lookup);
+			arg_vgid_lookup = NULL;
+		}
+	}
+
+	/*
+	 * Updated VG metadata has been sent from a command
+	 * for a VG but we have two VGs with this same name,
+	 * so we need to figure out which of the VGs it is.
+	 */
+	if (!pvid && arg_name_lookup && arg_vgid_lookup &&
+	    !strcmp(arg_name_lookup, arg_name) &&
+	     strcmp(arg_vgid_lookup, arg_vgid)) {
+		if ((arg_vgid2 = dm_hash_lookup_str_withval(s->vgname_to_vgid, arg_name, arg_vgid))) {
+			/* The first lookup found the another VG with the same name. */
+			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s update VG with same name as %s",
+				 arg_vgid, arg_name, arg_vgid_lookup);
+			arg_vgid_lookup = arg_vgid2;
+		} else {
+			/* This case is detected as an error below. */
+		}
+	}
+
+	/*
 	 * A new VG when there is no existing record of the name or vgid args.
 	 */
 	if (!arg_name_lookup && !arg_vgid_lookup) {
@@ -1397,7 +1442,22 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		}
 
 		new_vgid = arg_vgid;
-		old_vgid = dm_hash_lookup(s->vgname_to_vgid, arg_name);
+		old_vgid = dm_hash_lookup_str_multival(s->vgname_to_vgid, arg_name, &old_vgid2);
+
+		/*
+		 * FIXME: this ensures that arg_name maps to only one existing
+		 * VG (old_vgid), because if it maps to multiple vgids, then we
+		 * don't know which one should get the new vgid (arg_vgid).  If
+		 * this function was given both the existing name and existing
+		 * vgid to identify the VG, then this wouldn't be a problem.
+		 * But as it is now, the vgid arg to this function is the new
+		 * vgid and the existing VG is specified only by name.
+		 */
+		if (old_vgid && old_vgid2) {
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s found two vgids for name %s %s",
+			      arg_vgid, arg_name, old_vgid, old_vgid2);
+			old_vgid = NULL;
+		}
 
 		if (!old_vgid) {
 			/* This shouldn't happen. */
@@ -2633,6 +2693,11 @@ use_name:
 	if (!(uuid = dm_hash_lookup(s->vgname_to_vgid, name)))
 		goto out;
 
+	/* 
+	 * FIXME: if we only have the name and multiple VGs have that name,
+	 * then invalidate each of them.
+	 */
+
 	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, uuid)))
 		goto out;
 vers:
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 27fef53..30e6a2b 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -92,6 +92,10 @@ dm_hash_lookup_binary
 dm_hash_remove
 dm_hash_remove_binary
 dm_hash_wipe
+dm_hash_lookup_str_withval
+dm_hash_lookup_str_multival
+dm_hash_remove_str_withval
+dm_hash_insert_str_multival
 dm_is_dm_major
 dm_is_empty_dir
 dm_lib_exit
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 30b4a97..cf18226 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -208,6 +208,139 @@ void dm_hash_remove(struct dm_hash_table *t, const char *key)
 	dm_hash_remove_binary(t, key, strlen(key) + 1);
 }
 
+static struct dm_hash_node **_find_str_withval(struct dm_hash_table *t,
+					       const void *key, const void *val,
+					       uint32_t len, uint32_t val_len)
+{
+	struct dm_hash_node **c;
+	unsigned h;
+       
+	h = _hash(key, len) & (t->num_slots - 1);
+
+	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen != len)
+			continue;
+
+		if (!memcmp(key, (*c)->key, len) && (*c)->data) {
+			char *str = (char *)((*c)->data);
+
+			if (((strlen(str) + 1) == val_len) &&
+			    !memcmp(val, str, val_len))
+				return c;
+		}
+	}
+
+	return NULL;
+}
+
+int dm_hash_insert_str_multival(struct dm_hash_table *t, const char *key, const char *val)
+{
+	struct dm_hash_node *n;
+	struct dm_hash_node *first;
+	int len = strlen(key) + 1;
+	unsigned h;
+
+	n = _create_node(key, len);
+	if (!n)
+		return 0;
+
+	n->data = (void *)val;
+
+	h = _hash(key, len) & (t->num_slots - 1);
+
+	first = t->slots[h];
+
+	if (first)
+		n->next = first;
+	else
+		n->next = 0;
+	t->slots[h] = n;
+
+	t->num_nodes++;
+	return 1;
+}
+
+/*
+ * Look through multiple entries with the same key for one that has a
+ * matching val and return that.  If none have maching val, return NULL.
+ */
+void *dm_hash_lookup_str_withval(struct dm_hash_table *t, const char *key, const char *val)
+{
+	struct dm_hash_node **c;
+
+	c = _find_str_withval(t, key, val, strlen(key) + 1, strlen(val) + 1);
+
+	return (c && *c) ? (*c)->data : 0;
+}
+
+/*
+ * Look through multiple entries with the same key for one that has a
+ * matching val and remove that.
+ */
+void dm_hash_remove_str_withval(struct dm_hash_table *t, const char *key, const char *val)
+{
+	struct dm_hash_node **c;
+
+	c = _find_str_withval(t, key, val, strlen(key) + 1, strlen(val) + 1);
+
+	if (c && *c) {
+		struct dm_hash_node *old = *c;
+		*c = (*c)->next;
+		dm_free(old);
+		t->num_nodes--;
+	}
+}
+
+/*
+ * Look for multiple entries with the same key.
+ *
+ * If no entries have key, return NULL.
+ *
+ * If one entry has the key, the function returns the val,
+ * and sets val2 to NULL.
+ *
+ * If two entries have the key, the function returns the val
+ * from the first entry, and the val2 arg is set to the val
+ * from the second entry.
+ *
+ * If more than two entries have the key, the function looks
+ * at only the first two.
+ */
+void *dm_hash_lookup_str_multival(struct dm_hash_table *t, const char *key, const char **val2)
+{
+	struct dm_hash_node **c;
+	struct dm_hash_node **c1 = NULL;
+	struct dm_hash_node **c2 = NULL;
+	uint32_t len = strlen(key) + 1;
+	unsigned h;
+
+	h = _hash(key, len) & (t->num_slots - 1);
+
+	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen != len)
+			continue;
+
+		if (!memcmp(key, (*c)->key, len)) {
+			if (!c1) {
+				c1 = c;
+			} else if (!c2) {
+				c2 = c;
+				break;
+			}
+		}
+	}
+
+	if (!c2)
+		*val2 = NULL;
+	else
+		*val2 = (*c2)->data;
+
+	if (!c1)
+		return NULL;
+	else
+		return *c1 ? (*c1)->data : 0;
+}
+
 unsigned dm_hash_get_num_entries(struct dm_hash_table *t)
 {
 	return t->num_nodes;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index f7ab257..de2dc3e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1849,6 +1849,21 @@ void *dm_hash_get_data(struct dm_hash_table *t, struct dm_hash_node *n);
 struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t);
 struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n);
 
+/* 
+ * Using these requires that string values were inserted.
+ * They support the case where multiple values with the
+ * same key are inserted.
+ *
+ * The "withval" variants ensure that an entry matches
+ * both the specified key and value.  They are used to
+ * return or remove a unique entry by specifiying both
+ * the key and the value.
+ */
+int dm_hash_insert_str_multival(struct dm_hash_table *t, const char *key, const char *val);
+void *dm_hash_lookup_str_multival(struct dm_hash_table *t, const char *key, const char **val2);
+void *dm_hash_lookup_str_withval(struct dm_hash_table *t, const char *key, const char *val);
+void dm_hash_remove_str_withval(struct dm_hash_table *t, const char *key, const char *val);
+
 #define dm_hash_iterate(v, h) \
 	for (v = dm_hash_get_first((h)); v; \
 	     v = dm_hash_get_next((h), v))


