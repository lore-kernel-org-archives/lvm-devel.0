From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:51 +0100
Subject: [PATCH 10/15] Cache key from crypt mapping table if segment is active.
In-Reply-To: <3d899235af519a0e471dc86df580a991371b91fd.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
	<0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
	<b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
	<3d899235af519a0e471dc86df580a991371b91fd.1232488181.git.mbroz@redhat.com>
Message-ID: <35fcbf3ab1527b121e3a8064a35eab8f7a7a2f1d.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For some online operations (like lvresize) we need preload
new table, thus we need master key.

But the key is already in mapping table, do not ask
user and try to retrieve master key from mapping table first.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c    |   41 ++++++++++++++++++++++++++++++
 lib/activate/activate.h    |    5 +++
 lib/activate/dev_manager.c |   59 ++++++++++++++++++++++++++++++++++++++++++++
 lib/activate/dev_manager.h |    4 +++
 lib/metadata/crypt_manip.c |    6 ++++
 5 files changed, 115 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0f13cbd..0b17be8 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1117,6 +1117,47 @@ int pv_uses_vg(struct physical_volume *pv,
 	return dev_manager_device_uses_vg(pv->dev, vg);
 }
 
+/*
+ * Retrieve key for lv segment from dm table and cache it
+ */
+int lv_seg_cache_key(struct lv_segment *seg)
+{
+	char *key;
+	struct dev_manager *dm;
+	struct logical_volume *lv = seg->lv;
+	struct crypto_store *cs = seg->crypto_store;
+	int r;
+
+	if (!(key = dm_malloc(cs_key_bytes(cs) + 1)))
+		return_0;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name))) {
+		dm_free(key);
+		return_0;
+	}
+
+	if (!(r = dev_manager_crypt_key(dm, seg, key, cs_key_bytes(cs) + 1)))
+		stack;
+
+	dev_manager_destroy(dm);
+
+	if (!r)
+		goto out;
+
+	if (!lvm_masterkeys_verify(cs, key)) {
+		log_error("Internal error: Key in mapping table "
+			  "is not in expected format.");
+		goto out;
+	}
+
+	return lvm_masterkeys_insert(&cs->id, key);
+out:
+	memset(key, 0, cs_key_bytes(cs));
+	dm_free(key);
+	return 0;
+}
+
+
 void activation_release(void)
 {
 	dev_manager_release();
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index c5bd4b6..cc096a2 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -107,4 +107,9 @@ int pv_uses_vg(struct physical_volume *pv,
  */
 int device_is_usable(dev_t dev);
 
+/*
+ * Retrieve key for lv segment from dm table and cache it
+ */
+int lv_seg_cache_key(struct lv_segment *seg);
+
 #endif
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ef827ad..9be77f3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1272,3 +1272,62 @@ out:
 	dm_tree_free(dtree);
 	return r;
 }
+
+int dev_manager_crypt_key(struct dev_manager *dm, struct lv_segment *seg,
+			  char *buffer, int buffer_len)
+{
+	struct logical_volume *lv = seg->lv;
+	const char *dlid;
+	int r = 0;
+	struct dm_task *dmt;
+	struct dm_info info;
+	void *next = NULL;
+	uint64_t req_start, start, length;
+	char *type = NULL;
+	char *params = NULL;
+	char *key_start, *key_end;
+
+	// FIXME: secure pool operation & deallocate
+
+	/*
+	 * Build a name for the top layer.
+	 */
+	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL)))
+		return_0;
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_TABLE, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count");
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	req_start = seg->le * seg->lv->vg->extent_size;
+
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length,
+					  &type, &params);
+		if (req_start == start) {
+			if (!(key_start = strchr(params, ' ')))
+				break;
+			key_start++;
+			if (!(key_end = strchr(key_start, ' ')))
+				break;
+			if (key_end - key_start > buffer_len)
+				break;
+			strncpy(buffer, key_start, buffer_len);
+			buffer[buffer_len - 1] = '\0';
+			r = 1;
+			break;
+		}
+	} while (next);
+
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 7a76453..ac7cec9 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -17,6 +17,7 @@
 #define _LVM_DEV_MANAGER_H
 
 struct logical_volume;
+struct lv_segment;
 struct volume_group;
 struct cmd_context;
 struct dev_manager;
@@ -57,6 +58,9 @@ int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 int dev_manager_lv_mknodes(const struct logical_volume *lv);
 int dev_manager_lv_rmnodes(const struct logical_volume *lv);
 
+int dev_manager_crypt_key(struct dev_manager *dm, struct lv_segment *seg,
+			  char *buffer, int buffer_len);
+
 /*
  * Put the desired changes into effect.
  */
diff --git a/lib/metadata/crypt_manip.c b/lib/metadata/crypt_manip.c
index ff5c3e2..4b45a07 100644
--- a/lib/metadata/crypt_manip.c
+++ b/lib/metadata/crypt_manip.c
@@ -242,6 +242,12 @@ static int _seg_retrieve_masterkey(struct lv_segment *seg)
 	if (lvm_masterkeys_query(&seg->crypto_store->id))
 		return 1;
 
+	/*
+	 * Try to retrieve key from dm table
+	 */
+	if (lv_is_active(seg->lv) && lv_seg_cache_key(seg))
+		return 1;
+
 	return lvm_masterkeys_retrieve(seg->lv->name, seg->crypto_store);
 }
 
-- 
1.5.6.5


