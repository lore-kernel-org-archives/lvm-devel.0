From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:43 +0100
Subject: [PATCH 02/15] Add lvm-crypto header file with basic crypto struct definintions:
In-Reply-To: <f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
Message-ID: <1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - crypto_store_type it the crypto equivalent for segment type,
 it says how the crypto attributes are retrieved.
 In future there will be separate libraries
 which can provide various key stores.

 - crypto_store represents particular crypto store.
 Every crypt lv_segment must be linked to some crypto_store.
 Basically it says "how the cipher attributes and key" can
 be obtained for this segment.
 crypto_store can be shared by several LV segments.

 crypto_store can have special areas on disk (where it stores
 key material in some obfuscatted form - e.g. LUKS slots).

 If there is no area on disk, the cipher & key parameters
 can be stored directly in metadata (or provided through
 other interface - depends on crypto_store_type.)

 There are hardcoded attributes, which are mainly for
 supporting basic crypto segment operations
 (compatible mappings created by cryptsetup in non-luks mode)
 (see following patches).

 The keystore is identified by UUID (~= LV UUID)
 (Becuse crypto_store is represented by special LV,
  it is real LV UUID internally.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 include/.symlinks                |    1 +
 lib/crypt/lvm-crypto.h           |   65 ++++++++++++++++++++++++++++++++++++++
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/import_vsn1.c    |    1 +
 lib/metadata/metadata-exported.h |    5 +++
 lib/metadata/metadata.c          |    2 +
 7 files changed, 76 insertions(+), 0 deletions(-)
 create mode 100644 lib/crypt/lvm-crypto.h

diff --git a/include/.symlinks b/include/.symlinks
index 1a4bd93..4033e18 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -4,6 +4,7 @@
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
+../lib/crypt/lvm-crypto.h
 ../lib/commands/errors.h
 ../lib/commands/toolcontext.h
 ../lib/config/config.h
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
new file mode 100644
index 0000000..7ce3941
--- /dev/null
+++ b/lib/crypt/lvm-crypto.h
@@ -0,0 +1,65 @@
+/*
+ * Copyright (C) 2008-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_CRYPTO_H
+#define _LVM_CRYPTO_H
+
+#include "device.h"
+#include "uuid.h"
+
+/*
+ * Crypto config & key store
+ */
+struct crypto_store_type {
+	struct dm_list list;
+
+	const char *name;		/* cs type: plain/hashed/luks1 etc. */
+	uint32_t flags;			/* CS_IGNORE_* flags */
+	struct crypto_store_ops *ops;
+};
+
+struct crypto_store {
+	struct dm_list list;
+
+	int ref;			/* reference counter */
+	struct crypto_store_type *type;
+	struct dm_pool *mem;
+
+	struct id id;			/* ID, the same as LV id*/
+	const char *name;		/* Name used in crypt segments */
+	const char *type_name;		/* used if keystore type is unknown */
+
+	const char *cipher;		/* Cipher in dm-crypt form */
+	const char *keyhash;		/* Key hashing algorithm */
+	uint32_t key_size;		/* Master Key size in bits */
+
+	struct dm_list dev_areas;	/* disk areas maintained */
+};
+
+struct crypto_area_list {
+	struct dm_list list;
+	struct device_area area;
+};
+
+struct crypto_store_ops {
+	int (*scan) (struct device_area *da);
+	int (*master_key_retrieve) (struct crypto_store *cs,
+				    const char *name,
+				    char *buffer, unsigned buffer_len);
+	// int (*backup) (struct crypto_store *cs, ...);
+	// int (*restore) (struct crypto_store *cs, ...);
+	// FIXME: key management, area formatting functions, etc
+};
+
+#endif
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 8ab9363..a9ed088 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -130,6 +130,7 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	vg->seqno = 0;
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->crypto_stores);
 	dm_list_init(&vg->tags);
 
 	if (!_check_vgs(pvs))
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 0f72bd3..53c995f 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -124,6 +124,7 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	vg->system_id = NULL;
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->crypto_stores);
 	dm_list_init(&vg->tags);
 
 	if (!import_pool_vg(vg, smem, pds))
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index b7d06af..b610501 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -768,6 +768,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->crypto_stores);
 
 	/* Optional tags */
 	if ((cn = find_config_node(vgn, "tags")) &&
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 40ece6f..16c216a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -22,6 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
+#include "lvm-crypto.h"
 
 struct physical_volume;
 typedef struct physical_volume pv_t;
@@ -231,6 +232,8 @@ struct volume_group {
 	uint32_t snapshot_count;
 	struct dm_list lvs;
 
+	struct dm_list crypto_stores;
+
 	struct dm_list tags;
 };
 
@@ -271,6 +274,8 @@ struct lv_segment {
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
 
+	struct crypto_store *crypto_store;
+
 	struct dm_list tags;
 
 	struct lv_segment_area *areas;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a49c4d8..cb5dcbd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -546,6 +546,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 
 	vg->snapshot_count = 0;
 
+	dm_list_init(&vg->crypto_stores);
 	dm_list_init(&vg->tags);
 
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
@@ -1617,6 +1618,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	}
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->crypto_stores);
 	dm_list_init(&vg->tags);
 	vg->cmd = cmd;
 	if (!(vg->name = dm_pool_strdup(cmd->mem, orphan_vgname))) {
-- 
1.5.6.5


