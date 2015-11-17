From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:00:43 +0000 (UTC)
Subject: master - hash: change name of new lookup function
Message-ID: <20151117180043.DCC0C61041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=931fede81b5fdc3aecd730567fefc3e31c5275ce
Commit:        931fede81b5fdc3aecd730567fefc3e31c5275ce
Parent:        4d37db123d4ea2735c538bf9ad8a57be051ac9c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 11:59:44 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 11:59:44 2015 -0600

hash: change name of new lookup function

---
 daemons/lvmetad/lvmetad-core.c |    6 +++---
 libdm/.exported_symbols.Base   |    2 +-
 libdm/datastruct/hash.c        |    4 ++--
 libdm/libdevmapper.h           |    6 +++---
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 5bed562..7af9bde 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1101,7 +1101,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 		goto out;
 	}
 
-	if (!dm_hash_insert_multival(s->vgname_to_vgid, arg_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
+	if (!dm_hash_insert_allow_multiple(s->vgname_to_vgid, arg_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
 		ERROR(s, "update_metadata_new_vgid out of memory for vgid hash insert for %s %s", arg_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1215,7 +1215,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 		goto out;
 	}
 
-	if (!dm_hash_insert_multival(s->vgname_to_vgid, new_name, arg_vgid_dup, strlen(arg_vgid_dup) + 1)) {
+	if (!dm_hash_insert_allow_multiple(s->vgname_to_vgid, new_name, arg_vgid_dup, strlen(arg_vgid_dup) + 1)) {
 		ERROR(s, "update_metadata_new_name out of memory for vgid hash insert for %s %s", new_name, arg_vgid);
 		abort_daemon = 1;
 		goto out;
@@ -1284,7 +1284,7 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 		goto out;
 	}
 
-	if (!dm_hash_insert_multival(s->vgname_to_vgid, new_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
+	if (!dm_hash_insert_allow_multiple(s->vgname_to_vgid, new_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
 		ERROR(s, "update_metadata_add_new out of memory for vgid hash insert for %s %s", new_name, new_vgid);
 		abort_daemon = 1;
 		goto out;
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 47097fc..ee7c4f2 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -95,7 +95,7 @@ dm_hash_wipe
 dm_hash_lookup_with_val
 dm_hash_lookup_with_count
 dm_hash_remove_with_val
-dm_hash_insert_multival
+dm_hash_insert_allow_multiple
 dm_is_dm_major
 dm_is_empty_dir
 dm_lib_exit
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 2c5108d..f9b8b9c 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -232,8 +232,8 @@ static struct dm_hash_node **_find_str_with_val(struct dm_hash_table *t,
 	return NULL;
 }
 
-int dm_hash_insert_multival(struct dm_hash_table *t, const char *key,
-			    const void *val, uint32_t val_len)
+int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
+				  const void *val, uint32_t val_len)
 {
 	struct dm_hash_node *n;
 	struct dm_hash_node *first;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e02a3bc..6619aa7 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1859,7 +1859,7 @@ struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_no
  * val_len is the size of the data being inserted.
  *
  * If two entries with the same key exist,
- * (added using dm_hash_insert_multival), then:
+ * (added using dm_hash_insert_allow_multiple), then:
  * . dm_hash_lookup() returns the first one it finds, and
  *   dm_hash_lookup_with_val() returns the one with a matching
  *   val_len/val.
@@ -1897,8 +1897,8 @@ void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
                               const void *val, uint32_t val_len);
 void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
                              const void *val, uint32_t val_len);
-int dm_hash_insert_multival(struct dm_hash_table *t, const char *key,
-                            const void *val, uint32_t val_len);
+int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
+                                  const void *val, uint32_t val_len);
 void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count);
 
 


