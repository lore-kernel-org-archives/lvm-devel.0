From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 17 Nov 2015 16:29:32 +0000 (UTC)
Subject: master - lvmetad: different style for hash functions
Message-ID: <20151117162932.21AEA60D1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=485d2ca9454ab4725605ab9a33928164aef1bfc8
Commit:        485d2ca9454ab4725605ab9a33928164aef1bfc8
Parent:        d42cedae5818a50edde3ddb1db4bec6a2591c920
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 10:19:04 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 10:27:16 2015 -0600

lvmetad: different style for hash functions

In lookup, return a count of entries with the
same key rather than the value from a second
entry with the same key.

Using some slightly different names.
---
 daemons/lvmetad/lvmetad-core.c |   36 ++++++++++++++--------------
 libdm/.exported_symbols.Base   |    6 ++--
 libdm/datastruct/hash.c        |   50 ++++++++++++++++------------------------
 libdm/libdevmapper.h           |   32 ++++++++++++-------------
 4 files changed, 56 insertions(+), 68 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8e5bc37..5bed562 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -722,7 +722,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 	response res = { 0 };
 	const char *uuid = daemon_request_str(r, "uuid", NULL);
 	const char *name = daemon_request_str(r, "name", NULL);
-	const char *uuid2 = NULL;
+	int count = 0;
 
 	buffer_init( &res.buffer );
 
@@ -736,14 +736,14 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 		lock_vgid_to_metadata(s);
 		if (name && !uuid)
-			uuid = dm_hash_lookup_multival(s->vgname_to_vgid, name, (void *)&uuid2);
+			uuid = dm_hash_lookup_with_count(s->vgname_to_vgid, name, &count);
 		else if (uuid && !name)
 			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
 		unlock_vgid_to_metadata(s);
 
-		if (name && uuid && uuid2) {
-			DEBUGLOG(s, "vg_lookup name %s found multiple vgids %s %s",
-				 name, uuid, uuid2);
+		if (name && uuid && (count > 1)) {
+			DEBUGLOG(s, "vg_lookup name %s vgid %s found %d vgids",
+				 name, uuid, count);
 			return daemon_reply_simple("multiple", "reason = %s", "Multiple VGs found with same name", NULL);
 		}
 
@@ -752,7 +752,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	} else {
 		char *name_lookup = dm_hash_lookup(s->vgid_to_vgname, uuid);
-		char *uuid_lookup = dm_hash_lookup_withval(s->vgname_to_vgid, name, uuid, strlen(uuid) + 1);
+		char *uuid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, name, uuid, strlen(uuid) + 1);
 
 		/* FIXME: comment out these sanity checks when not testing */
 
@@ -923,7 +923,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	name_lookup = dm_hash_lookup(s->vgid_to_vgname, vgid);
 	outdated_pvs_lookup = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
 	if (name_lookup)
-		vgid_lookup = dm_hash_lookup_withval(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
+		vgid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
 
 	/* remove hash table mappings */
 
@@ -932,7 +932,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	dm_hash_remove(s->vgid_to_vgname, vgid);
 	dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
 	if (name_lookup)
-		dm_hash_remove_withval(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
+		dm_hash_remove_with_val(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
 
 	unlock_vgid_to_metadata(s);
 
@@ -1012,8 +1012,8 @@ static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *
 	lock_pvid_to_vgid(s);
 	remove_metadata(s, arg_vgid, 1);
 
-	if ((rem_vgid = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
-		dm_hash_remove_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
+	if ((rem_vgid = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
+		dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
 		dm_free(rem_vgid);
 	}
 	unlock_pvid_to_vgid(s);
@@ -1080,7 +1080,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	dm_config_destroy(old_meta);
 	old_meta = NULL;
 
-	dm_hash_remove_withval(s->vgname_to_vgid, arg_name, old_vgid, strlen(old_vgid) + 1);
+	dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, old_vgid, strlen(old_vgid) + 1);
 	dm_hash_remove(s->vgid_to_vgname, old_vgid);
 	dm_free((char *)old_vgid);
 	old_vgid = NULL;
@@ -1195,7 +1195,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	old_meta = NULL;
 
 	dm_hash_remove(s->vgid_to_vgname, arg_vgid);
-	dm_hash_remove_withval(s->vgname_to_vgid, old_name, arg_vgid, strlen(arg_vgid) + 1);
+	dm_hash_remove_with_val(s->vgname_to_vgid, old_name, arg_vgid, strlen(arg_vgid) + 1);
 	dm_free((char *)old_name);
 	old_name = NULL;
 
@@ -1345,13 +1345,13 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	const char *new_name = NULL;
 	const char *old_vgid = NULL;
 	const char *new_vgid = NULL;
-	const char *old_vgid2 = NULL;
 	const char *new_metadata_vgid;
 	int old_seq = -1;
 	int new_seq = -1;
 	int needs_repair = 0;
 	int abort_daemon = 0;
 	int retval = 0;
+	int count = 0;
 
 	if (!arg_vgid || !arg_name) {
 		ERROR(s, "update_metadata missing args arg_vgid %s arg_name %s pvid %s",
@@ -1372,7 +1372,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 
 	lock_vgid_to_metadata(s);
 	arg_name_lookup = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
-	arg_vgid_lookup = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
+	arg_vgid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
 
 	/*
 	 * A new VG when there is no existing record of the name or vgid args.
@@ -1404,7 +1404,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		}
 
 		new_vgid = arg_vgid;
-		old_vgid = dm_hash_lookup_multival(s->vgname_to_vgid, arg_name, (void *)&old_vgid2);
+		old_vgid = dm_hash_lookup_with_count(s->vgname_to_vgid, arg_name, &count);
 
 		/*
 		 * FIXME: this ensures that arg_name maps to only one existing
@@ -1415,9 +1415,9 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		 * But as it is now, the vgid arg to this function is the new
 		 * vgid and the existing VG is specified only by name.
 		 */
-		if (old_vgid && old_vgid2) {
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s found two vgids for name %s %s",
-			      arg_vgid, arg_name, old_vgid, old_vgid2);
+		if (old_vgid && (count > 1)) {
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s found %d vgids for name",
+			      arg_vgid, arg_name, count);
 			old_vgid = NULL;
 		}
 
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 61df67c..47097fc 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -92,9 +92,9 @@ dm_hash_lookup_binary
 dm_hash_remove
 dm_hash_remove_binary
 dm_hash_wipe
-dm_hash_lookup_withval
-dm_hash_lookup_multival
-dm_hash_remove_withval
+dm_hash_lookup_with_val
+dm_hash_lookup_with_count
+dm_hash_remove_with_val
 dm_hash_insert_multival
 dm_is_dm_major
 dm_is_empty_dir
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 406f5fd..2c5108d 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -209,9 +209,9 @@ void dm_hash_remove(struct dm_hash_table *t, const char *key)
 	dm_hash_remove_binary(t, key, strlen(key) + 1);
 }
 
-static struct dm_hash_node **_find_str_withval(struct dm_hash_table *t,
-					       const void *key, const void *val,
-					       uint32_t len, uint32_t val_len)
+static struct dm_hash_node **_find_str_with_val(struct dm_hash_table *t,
+					        const void *key, const void *val,
+					        uint32_t len, uint32_t val_len)
 {
 	struct dm_hash_node **c;
 	unsigned h;
@@ -265,12 +265,12 @@ int dm_hash_insert_multival(struct dm_hash_table *t, const char *key,
  * Look through multiple entries with the same key for one that has a
  * matching val and return that.  If none have maching val, return NULL.
  */
-void *dm_hash_lookup_withval(struct dm_hash_table *t, const char *key,
-			     const void *val, uint32_t val_len)
+void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
+			      const void *val, uint32_t val_len)
 {
 	struct dm_hash_node **c;
 
-	c = _find_str_withval(t, key, val, strlen(key) + 1, val_len);
+	c = _find_str_with_val(t, key, val, strlen(key) + 1, val_len);
 
 	return (c && *c) ? (*c)->data : 0;
 }
@@ -279,12 +279,12 @@ void *dm_hash_lookup_withval(struct dm_hash_table *t, const char *key,
  * Look through multiple entries with the same key for one that has a
  * matching val and remove that.
  */
-void dm_hash_remove_withval(struct dm_hash_table *t, const char *key,
-			    const void *val, uint32_t val_len)
+void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
+			     const void *val, uint32_t val_len)
 {
 	struct dm_hash_node **c;
 
-	c = _find_str_withval(t, key, val, strlen(key) + 1, val_len);
+	c = _find_str_with_val(t, key, val, strlen(key) + 1, val_len);
 
 	if (c && *c) {
 		struct dm_hash_node *old = *c;
@@ -295,28 +295,26 @@ void dm_hash_remove_withval(struct dm_hash_table *t, const char *key,
 }
 
 /*
- * Look for multiple entries with the same key.
+ * Look up the value for a key and count how many
+ * entries have the same key.
  *
- * If no entries have key, return NULL.
+ * If no entries have key, return NULL and set count to 0.
  *
  * If one entry has the key, the function returns the val,
- * and sets val2 to NULL.
- *
- * If two entries have the key, the function returns the val
- * from the first entry, and the val2 arg is set to the val
- * from the second entry.
+ * and sets count to 1.
  *
- * If more than two entries have the key, the function looks
- * at only the first two.
+ * If N entries have the key, the function returns the val
+ * from the first entry, and sets count to N.
  */
-void *dm_hash_lookup_multival(struct dm_hash_table *t, const char *key, const void **val2)
+void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count)
 {
 	struct dm_hash_node **c;
 	struct dm_hash_node **c1 = NULL;
-	struct dm_hash_node **c2 = NULL;
 	uint32_t len = strlen(key) + 1;
 	unsigned h;
 
+	*count = 0;
+
 	h = _hash(key, len) & (t->num_slots - 1);
 
 	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
@@ -324,20 +322,12 @@ void *dm_hash_lookup_multival(struct dm_hash_table *t, const char *key, const vo
 			continue;
 
 		if (!memcmp(key, (*c)->key, len)) {
-			if (!c1) {
+			(*count)++;
+			if (!c1)
 				c1 = c;
-			} else if (!c2) {
-				c2 = c;
-				break;
-			}
 		}
 	}
 
-	if (!c2)
-		*val2 = NULL;
-	else
-		*val2 = (*c2)->data;
-
 	if (!c1)
 		return NULL;
 	else
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2c3900b..e02a3bc 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1854,27 +1854,27 @@ struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_no
  * entry with a matching key if one exists.  Otherwise
  * it adds a new entry.
  *
- * dm_hash_insert_withval() inserts a new entry if
+ * dm_hash_insert_with_val() inserts a new entry if
  * another entry with the same key already exists.
  * val_len is the size of the data being inserted.
  *
  * If two entries with the same key exist,
  * (added using dm_hash_insert_multival), then:
  * . dm_hash_lookup() returns the first one it finds, and
- *   dm_hash_lookup_withval() returns the one with a matching
+ *   dm_hash_lookup_with_val() returns the one with a matching
  *   val_len/val.
  * . dm_hash_remove() removes the first one it finds, and
- *   dm_hash_remove_withval() removes the one with a matching
+ *   dm_hash_remove_with_val() removes the one with a matching
  *   val_len/val.
  *
  * If a single entry with a given key exists, and it has
  * zero val_len, then:
  * . dm_hash_lookup() returns it
- * . dm_hash_lookup_withval(val_len=0) returns it
+ * . dm_hash_lookup_with_val(val_len=0) returns it
  * . dm_hash_remove() removes it
- * . dm_hash_remove_withval(val_len=0) removes it
+ * . dm_hash_remove_with_val(val_len=0) removes it
  *
- * dm_hash_lookup_multival() is a single call that will
+ * dm_hash_lookup_with_count() is a single call that will
  * both lookup a key's value and check if there is more
  * than one entry with the given key.
  *
@@ -1884,24 +1884,22 @@ struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_no
  * both look up the value and indicate if multiple values
  * exist for the key.)
  *
- * dm_hash_lookup_multival:
+ * dm_hash_lookup_with_count:
  * . If no entries exist, the function returns NULL, and
- *   the val2 arg is set to NULL.
+ *   the count is set to 0.
  * . If only one entry exists, the value of that entry is
- *   returned and the val2 arg is set to NULL.
- * . If more than one entry exists, the value of one entry
- *   is returned and the val2 arg is set to the value of a
- *   second entry.  Testing that the val2 arg is not NULL
- *   indicates that more than one entry exists.
+ *   returned and count is set to 1.
+ * . If N entries exists, the value of the first entry is
+ *   returned and count is set to N.
  */
 
-void *dm_hash_lookup_withval(struct dm_hash_table *t, const char *key,
+void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
+                              const void *val, uint32_t val_len);
+void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
                              const void *val, uint32_t val_len);
-void dm_hash_remove_withval(struct dm_hash_table *t, const char *key,
-                            const void *val, uint32_t val_len);
 int dm_hash_insert_multival(struct dm_hash_table *t, const char *key,
                             const void *val, uint32_t val_len);
-void *dm_hash_lookup_multival(struct dm_hash_table *t, const char *key, const void **val2);
+void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count);
 
 
 #define dm_hash_iterate(v, h) \


