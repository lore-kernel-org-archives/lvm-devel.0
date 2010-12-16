From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:10 +0100
Subject: [PATCH 02/20] Const fixes and additions
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <9a3c1a9281fbdf97f3f23a93f4971ff5df7d9186.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c           |    4 ++--
 lib/datastruct/btree.c        |    2 +-
 lib/format_pool/format_pool.c |    2 +-
 lib/format_text/import.c      |    2 +-
 lib/metadata/metadata.h       |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 6477877..1df8d09 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -239,8 +239,8 @@ int read_config_fd(struct config_tree *cft, struct device *dev,
 	}
 
 	if (checksum_fn && checksum !=
-	    (checksum_fn(checksum_fn(INITIAL_CRC, (uint8_t *)p->fb, size),
-			 (uint8_t *)(p->fb + size), size2))) {
+	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)p->fb, size),
+			 (const uint8_t *)(p->fb + size), size2))) {
 		log_error("%s: Checksum error", dev_name(dev));
 		goto out;
 	}
diff --git a/lib/datastruct/btree.c b/lib/datastruct/btree.c
index 9446008..bfcdca6 100644
--- a/lib/datastruct/btree.c
+++ b/lib/datastruct/btree.c
@@ -103,7 +103,7 @@ int btree_insert(struct btree *t, uint32_t k, void *data)
 
 void *btree_get_data(const struct btree_iter *it)
 {
-	return ((struct node *) it)->data;
+	return ((const struct node *) it)->data;
 }
 
 static struct node *_left(struct node *n)
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 04b5611..545195b 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -75,7 +75,7 @@ static struct user_subpool *_build_usp(struct dm_list *pls, struct dm_pool *mem,
 	return usp;
 }
 
-static int _check_usp(char *vgname, struct user_subpool *usp, int sp_count)
+static int _check_usp(const char *vgname, struct user_subpool *usp, int sp_count)
 {
 	int i;
 	unsigned j;
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 3e0df94..60f465f 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -131,7 +131,7 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 				 when, desc);
 }
 
-struct volume_group *import_vg_from_buffer(char *buf,
+struct volume_group *import_vg_from_buffer(const char *buf,
                                            struct format_instance *fid)
 {
 	struct volume_group *vg = NULL;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6ed467e..815e460 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -386,7 +386,7 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
-struct volume_group *import_vg_from_buffer(char *buf,
+struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
 
 /*
-- 
1.7.3.3


