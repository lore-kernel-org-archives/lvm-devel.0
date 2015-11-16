From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 Nov 2015 17:02:58 +0000 (UTC)
Subject: master - hash: add comment about multiple values
Message-ID: <20151116170258.A2A27609D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=920a28199411445f6489912efd5b8bfca00dc588
Commit:        920a28199411445f6489912efd5b8bfca00dc588
Parent:        b6a45963e341d85196fcb070026180b3c62d608f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 16 11:01:53 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 16 11:02:25 2015 -0600

hash: add comment about multiple values

---
 libdm/libdevmapper.h |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a240d0e..2c3900b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1849,6 +1849,52 @@ void *dm_hash_get_data(struct dm_hash_table *t, struct dm_hash_node *n);
 struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t);
 struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n);
 
+/*
+ * dm_hash_insert() replaces the value of an existing
+ * entry with a matching key if one exists.  Otherwise
+ * it adds a new entry.
+ *
+ * dm_hash_insert_withval() inserts a new entry if
+ * another entry with the same key already exists.
+ * val_len is the size of the data being inserted.
+ *
+ * If two entries with the same key exist,
+ * (added using dm_hash_insert_multival), then:
+ * . dm_hash_lookup() returns the first one it finds, and
+ *   dm_hash_lookup_withval() returns the one with a matching
+ *   val_len/val.
+ * . dm_hash_remove() removes the first one it finds, and
+ *   dm_hash_remove_withval() removes the one with a matching
+ *   val_len/val.
+ *
+ * If a single entry with a given key exists, and it has
+ * zero val_len, then:
+ * . dm_hash_lookup() returns it
+ * . dm_hash_lookup_withval(val_len=0) returns it
+ * . dm_hash_remove() removes it
+ * . dm_hash_remove_withval(val_len=0) removes it
+ *
+ * dm_hash_lookup_multival() is a single call that will
+ * both lookup a key's value and check if there is more
+ * than one entry with the given key.
+ *
+ * (It is not meant to retrieve all the entries with the
+ * given key.  In the common case where a single entry exists
+ * for the key, it is useful to have a single call that will
+ * both look up the value and indicate if multiple values
+ * exist for the key.)
+ *
+ * dm_hash_lookup_multival:
+ * . If no entries exist, the function returns NULL, and
+ *   the val2 arg is set to NULL.
+ * . If only one entry exists, the value of that entry is
+ *   returned and the val2 arg is set to NULL.
+ * . If more than one entry exists, the value of one entry
+ *   is returned and the val2 arg is set to the value of a
+ *   second entry.  Testing that the val2 arg is not NULL
+ *   indicates that more than one entry exists.
+ */
+
 void *dm_hash_lookup_withval(struct dm_hash_table *t, const char *key,
                              const void *val, uint32_t val_len);
 void dm_hash_remove_withval(struct dm_hash_table *t, const char *key,


