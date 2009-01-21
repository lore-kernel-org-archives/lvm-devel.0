From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:48 +0100
Subject: [PATCH 07/15] Add "crypt" and "crypt-keystore" segment implementation.
In-Reply-To: <6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
Message-ID: <0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The "crypt" segment is direct equivalent to "linear"
segment, except it is encrypted of course.

For segment are defined the same flags to easily
re-use all lvm functions already using linear segment type.

It also implements merging of crypto segments.

New flag SEG_AREAS_ENCRYPTED is used to distinguish
between linear and encrypted segment.

The "crypt" segment must have assigned crypto_store
(for validation code enforcing this see following patch).

METADATA example:

	segment1 {
		start_extent = 0
		extent_count = 4        # 16 Megabytes

		type = "crypt"
		crypto_store = "cryptostore3"

		areas = [
			"pv2", 0
		]
	}

(crypto_store references special LV by its name in the same VG)

The "crypt-keystore" segment describes special part of disk,
which is never activated with any logical volume, except
for key management operation.
(Activation is currently simply ignored).

(Following code implements crypto store as special LV,
only "crypt-keystore" segments can be included in this
special LV.)

Keystore segment should always include only physical areas
(but the restriction is not hardcoded).

Currently only one area for crypto segment and one "crypt-keystore"
segment per special LV is supported.

METADATA examples:
 - "plain" handler, no areas

		segment1 {
			start_extent = 0
			extent_count = 0        # 0 Kilobytes

			type = "crypt-keystore"
			handler = "plain"
			cipher = "aes-xts-plain"
			key_size = 256  # 32 Bytes
		}

 - "luks1" handler using keyslots on disk
   (cipher, key_size, etc. are stored in this area too)

		segment1 {
			start_extent = 0
			extent_count = 1        # 4 Megabytes

			type = "crypt-keystore"
			handler = "luks1"

			areas = [
				"pv0", 3
			]
		}

For unknown handler it retains these attributes:
	cipher, key_size, key_hash

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/Makefile.in                  |    1 +
 lib/crypt/crypt.c                |  332 +++++++++++++++++++++++++++++++++++++-
 lib/crypt/lvm-crypto.h           |    7 +
 lib/metadata/crypt_manip.c       |  118 ++++++++++++++
 lib/metadata/metadata-exported.h |    9 +
 5 files changed, 465 insertions(+), 2 deletions(-)
 create mode 100644 lib/metadata/crypt_manip.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 7971395..7167f04 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -69,6 +69,7 @@ SOURCES =\
 	locking/locking.c \
 	locking/no_locking.c \
 	log/log.c \
+	metadata/crypt_manip.c \
 	metadata/lv_manip.c \
 	metadata/merge.c \
 	metadata/metadata.c \
diff --git a/lib/crypt/crypt.c b/lib/crypt/crypt.c
index c6658c8..6dae88f 100644
--- a/lib/crypt/crypt.c
+++ b/lib/crypt/crypt.c
@@ -25,20 +25,348 @@
 #include "toolcontext.h"
 #include "lvm-crypto.h"
 
+static const char *_crypt_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+static void _crypt_display(const struct lv_segment *seg)
+{
+	log_print("  Key Handler\t\t%s", cs_handler_name(seg->crypto_store));
+	display_stripe(seg, 0, "  ");
+	log_print(" ");
+}
+
+static int _crypt_text_import_area_count(struct config_node *sn, uint32_t *area_count)
+{
+	/*
+	 * Crypt can support multiple segments, but only one area per segment.
+	 */
+	*area_count = 1;
+
+	return 1;
+}
+
+static int _keystore_text_import_area_count(struct config_node *sn, uint32_t *area_count)
+{
+	/*
+	 * Crypt key store can use area on disk, simply check if it is in metadata
+	 */
+	if (find_config_node(sn, "areas"))
+		*area_count = 1;
+	else
+		*area_count = 0;
+
+	return 1;
+}
+
+static int _crypt_text_import(struct lv_segment *seg, const struct config_node *sn,
+			struct dm_hash_table *pv_hash)
+{
+	struct config_node *cn;
+	char *cs_name = NULL;
+
+	if (!get_config_str(sn, "crypto_store", &cs_name)) {
+		log_error("Couldn't find crypto_store for %s.", sn->key);
+		return 0;
+	}
+
+	if (!seg_assign_cryptostore(seg, cs_name, NULL)) {
+		log_error("Crypto store %s is not defined.", cs_name);
+		return 0;
+	}
+	seg->crypto_store->ref++;
+
+	if (!(cn = find_config_node(sn, "areas"))) {
+		log_error("Couldn't find areas array for segment "
+			  "'%s'.", sn->key);
+		return 0;
+	}
+
+	return text_import_areas(seg, sn, cn, pv_hash, 0);
+}
+
+static int _keystore_text_import(struct lv_segment *seg, const struct config_node *sn,
+			struct dm_hash_table *pv_hash)
+{
+	struct crypto_store *cs;
+	struct crypto_store_type *cst;
+	struct config_node *cn;
+	char *cs_handler = NULL, *cipher = NULL, *keyhash = NULL;
+
+	if (!get_config_str(sn, "handler", &cs_handler)) {
+		log_error("Missing handler specification for crypto store.");
+		return 0;
+	}
+
+	cst = lvm_get_keystore_handler(cs_handler);
+
+	if (!seg_assign_cryptostore(seg, seg->lv->name, cst)) {
+		log_error("Crypto store %s cannot be created.", seg->lv->name);
+		return 0;
+	}
+
+	/*
+	 * Now is the crypto store in seg surely allocated
+	 */
+	cs = seg->crypto_store;
+
+	/*
+	 * If we have no handler, store type_name
+	 * (to allow export metadata for not loaded keyhandler)
+	 */
+	if (!cst) {
+		if (!(cs->type_name = dm_pool_strdup(cs->mem, cs_handler)))
+			return_0;
+		log_debug("Unknown crypto store type %s, LVs using it cannot "
+			 "be activated.", cs_handler);
+	}
+
+	cs->id = seg->lv->lvid.id[1];
+
+	if (cs_store_cipher(cs)) {
+		if (!get_config_str(sn, "cipher", &cipher) && cst) {
+			log_error("Missing cipher specification for %s.", cs_handler);
+			return 0;
+		}
+
+		if (cipher && !(cs->cipher = dm_pool_strdup(cs->mem, cipher)))
+			return_0;
+	}
+
+	if (cs_store_keyhash(cs)) {
+		if (!get_config_str(sn, "key_hash", &keyhash) && cst) {
+			log_error("Missing key hash specification for %s.", cs_handler);
+			return 0;
+		}
+
+		if (keyhash && !(cs->keyhash = dm_pool_strdup(cs->mem, keyhash)))
+			return_0;
+	}
+
+	if (cs_store_keylen(cs))
+		if (!get_config_uint32(sn, "key_size", &cs->key_size) && cst) {
+			log_error("Missing key length specification for %s.", cs_handler);
+			return 0;
+		}
+
+	if (seg->area_count == 0)
+		return 1;
+
+	if (!(cn = find_config_node(sn, "areas"))) {
+		log_error("Couldn't find areas array for segment '%s'.", sn->key);
+		return 0;
+	}
+
+	if (!text_import_areas(seg, sn, cn, pv_hash, 0))
+		return 0;
+
+	if (!seg_assign_crypto_store_areas(seg)) {
+		log_error("Couldn't convert LV areas to crypto store areas.");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _crypt_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	if (seg->crypto_store)
+		outf(f, "crypto_store = \"%s\"", seg->crypto_store->name);
+
+	return out_areas(f, seg, "area");
+}
+
+static int _keystore_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	struct crypto_store *cs = seg->crypto_store;
+
+	outf(f, "handler = \"%s\"", cs_handler_name(cs));
+
+	/*
+	 * For unknown keystore, default is retain all previously read attributes
+	 */
+	if (cs_store_cipher(cs) && cs->cipher)
+		outf(f, "cipher = \"%s\"", cs->cipher);
+
+	if (cs_store_keylen(cs) && cs->key_size)
+		outf(f, "key_size = %u\t# %u Bytes", cs->key_size, cs->key_size / 8);
+
+	if (cs_store_keyhash(cs) && cs->keyhash)
+		outf(f, "key_hash = \"%s\"", cs->keyhash);
+
+	return seg->area_count ? out_areas(f, seg, "area") : 1;
+}
+
+static int _crypt_merge_segments(struct lv_segment *seg1, struct lv_segment *seg2)
+{
+	/*
+	 * Check if segments are compatible
+	 * Area count is always 1.
+	 */
+	if ((seg_type(seg1, 0) != AREA_PV) ||
+	    (seg_type(seg2, 0) != AREA_PV))
+		return 0;
+
+	if (seg1->crypto_store != seg2->crypto_store)
+		return 0;
+
+	if (!str_list_lists_equal(&seg1->tags, &seg2->tags))
+		return 0;
+
+	if ((seg_pv(seg1, 0) != seg_pv(seg2, 0)) ||
+	    (seg_pe(seg1, 0) + seg1->area_len != seg_pe(seg2, 0)))
+		return 0;
+
+	/*
+	 * Merge segments
+	 */
+	seg1->len += seg2->len;
+	seg1->area_len += seg2->area_len;
+
+	merge_pv_segments(seg_pvseg(seg1, 0), seg_pvseg(seg2, 0));
+
+	return 1;
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _crypt_add_target_line(struct dev_manager *dm,
+				struct dm_pool *mem __attribute((unused)),
+				struct cmd_context *cmd __attribute((unused)),
+				void **target_state __attribute((unused)),
+				struct lv_segment *seg,
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count __attribute((unused)))
+{
+	struct crypto_store *cs = seg->crypto_store;
+
+	/*
+	 * Caller must ensure that master key is already in cache
+	 */
+	if(!dm_tree_node_add_crypt_target(node, len, cs->cipher, lvm_masterkeys_query(&cs->id)))
+		return_0;
+
+	return add_areas_line(dm, seg, node, 0u, seg->area_count);
+}
+
+static int _keystore_add_target_line(struct dev_manager *dm,
+				struct dm_pool *mem __attribute((unused)),
+				struct cmd_context *cmd __attribute((unused)),
+				void **target_state __attribute((unused)),
+				struct lv_segment *seg,
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count __attribute((unused)))
+{
+	/*
+	 * FIXME: allow activation only for Key Management operations here
+	 *
+	if (!dm_tree_node_add_linear_target(node, len))
+		return_0;
+
+	return add_areas_line(dm, seg, node, 0u, seg->area_count);
+	 */
+
+	return 0;
+}
+
+static int _crypt_target_present(const struct lv_segment *seg __attribute((unused)),
+				   unsigned *attributes __attribute((unused)))
+{
+	static int _crypt_checked = 0;
+	static int _crypt_present = 0;
+
+	if (!_crypt_checked)
+		_crypt_present = target_present("crypt", 0);
+
+	_crypt_checked = 1;
+
+	return _crypt_present;
+}
+#endif
+
+static int _crypt_modules_needed(struct dm_pool *mem,
+				const struct lv_segment *seg __attribute((unused)),
+				struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, "crypt")) {
+		log_error("crypt module string list allocation failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _crypt_destroy(const struct segment_type *segtype)
+{
+	dm_free((void *)segtype);
+}
+
 /*
  * "crypt" segment - using real crypt target directly
  */
+static struct segtype_handler _crypt_ops = {
+	.name			= _crypt_name,
+	.display		= _crypt_display,
+	.text_import_area_count	= _crypt_text_import_area_count,
+	.text_import		= _crypt_text_import,
+	.text_export		= _crypt_text_export,
+	.merge_segments		= _crypt_merge_segments,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line	= _crypt_add_target_line,
+	.target_present		= _crypt_target_present,
+#endif
+	.modules_needed		= _crypt_modules_needed,
+	.destroy		= _crypt_destroy,
+};
+
 struct segment_type *init_crypt_segtype(struct cmd_context *cmd)
 {
-	return NULL;
+	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+	segtype->ops = &_crypt_ops;
+	segtype->name = "crypt";
+	segtype->private = NULL;
+	segtype->flags = SEG_AREAS_STRIPED |SEG_AREAS_ENCRYPTED | SEG_CAN_SPLIT;
+
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
 }
 
 /*
  * "crypt-keystore" segment - area for storing keys, need specific handler
  * (e.g. LUKS metadata space)
  */
+static struct segtype_handler _keystore_ops = {
+	.name			= _crypt_name,
+	.display		= _crypt_display,
+	.text_import_area_count	= _keystore_text_import_area_count,
+	.text_import		= _keystore_text_import,
+	.text_export		= _keystore_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line 	= _keystore_add_target_line,
+#endif
+	.destroy		= _crypt_destroy,
+};
 
 struct segment_type *init_keystore_segtype(struct cmd_context *cmd)
 {
-	return NULL;
+	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+	segtype->ops = &_keystore_ops;
+	segtype->name = "crypt-keystore";
+	segtype->private = NULL;
+	segtype->flags = SEG_AREAS_STRIPED | SEG_AREAS_ENCRYPTED | SEG_CANNOT_BE_ZEROED;
+
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
 }
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
index 3ebddce..6ed2d91 100644
--- a/lib/crypt/lvm-crypto.h
+++ b/lib/crypt/lvm-crypto.h
@@ -23,6 +23,9 @@
  */
 typedef const char *masterkey_t;
 
+struct lv_segment;
+struct logical_volume;
+
 /*
  * Flags says if attribute is stored in keystore area and not in LVM metadata.
  * By default, all generic attributes in LVM metadata must be retained
@@ -111,4 +114,8 @@ struct crypto_store_type *lvm_get_keystore_handler(const char *name);
 int lvm_set_password_dev(const char *password_file);
 int lvm_read_password(char *message, char *pass, size_t len);
 
+struct device_area *first_crypto_area(struct crypto_store *cs);
+int seg_assign_crypto_store_areas(struct lv_segment *seg);
+int seg_assign_cryptostore(struct lv_segment *seg, const char *name,
+                           struct crypto_store_type *cst);
 #endif
diff --git a/lib/metadata/crypt_manip.c b/lib/metadata/crypt_manip.c
new file mode 100644
index 0000000..59e40b9
--- /dev/null
+++ b/lib/metadata/crypt_manip.c
@@ -0,0 +1,118 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#include "lib.h"
+#include "metadata.h"
+#include "toolcontext.h"
+#include "lv_alloc.h"
+#include "segtype.h"
+#include "activate.h"
+
+struct crypto_store *alloc_cryptostore(struct dm_pool *mem, const char *name,
+				       struct crypto_store_type *cst)
+{
+	struct crypto_store *cs;
+
+	cs = dm_pool_zalloc(mem, sizeof(struct crypto_store));
+	if (!cs)
+		return_NULL;
+
+	cs->mem = mem;
+	cs->type = cst;
+	if (!(cs->name = dm_pool_strdup(cs->mem, name)))
+		return_NULL;
+
+	dm_list_init(&cs->dev_areas);
+
+	return cs;
+}
+
+/*
+ * Crypto area helpers
+ */
+struct device_area *first_crypto_area(struct crypto_store *cs)
+{
+	struct crypto_area_list *da = NULL;
+
+	dm_list_iterate_items(da, &cs->dev_areas)
+		break;
+
+	return da ? &da->area : NULL;
+}
+
+int seg_assign_crypto_store_areas(struct lv_segment *seg)
+{
+	struct crypto_area_list *cal;
+
+	if (seg->area_count == 0)
+		return 1;
+
+	if (seg->area_count > 1)
+		return 0;
+
+	if (!(cal = dm_pool_zalloc(seg->crypto_store->mem, sizeof(*cal))))
+		return_0;
+
+	cal->area.dev = seg_dev(seg, 0);
+	cal->area.start = seg_pv(seg, 0)->pe_start +
+			  seg->lv->vg->extent_size * seg_pe(seg, 0);
+	cal->area.start <<= SECTOR_SHIFT;
+	cal->area.size = seg->lv->vg->extent_size * seg_pvseg(seg, 0)->len;
+
+	dm_list_add(&seg->crypto_store->dev_areas, &cal->list);
+
+	return 1;
+}
+
+/*
+ * We cannot guarantee that LV segment is read after cryptostore LV
+ * Code can allocate empty cryptostore, which get set up later
+ * vg_validate must check against unconfigured cryptostores.
+ */
+int seg_assign_cryptostore(struct lv_segment *seg, const char *name,
+			   struct crypto_store_type *cst)
+{
+	struct volume_group *vg = seg->lv->vg;
+	struct crypto_store *cs;
+
+	if (!(cs = find_crypto_store_in_vg(vg, name))) {
+		if (!(cs = alloc_cryptostore(vg->cmd->mem, name, cst)))
+			return_0;
+
+		dm_list_add(&vg->crypto_stores, &cs->list);
+	}
+
+	// FIXME: remove this test
+	if (seg->crypto_store && seg->crypto_store != cs)
+		log_error("Internal error: cryptostore mismatch.");
+
+	if (cst)
+		cs->type = cst;
+
+	seg->crypto_store = cs;
+
+	return 1;
+}
+
+struct crypto_store *find_crypto_store_in_vg(struct volume_group *vg,
+					     const char *cs_name)
+{
+	struct crypto_store *cs;
+
+	dm_list_iterate_items(cs, &vg->crypto_stores)
+		if (!strcmp(cs->name, cs_name))
+			return cs;
+
+	return NULL;
+}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 16c216a..2aa5a1b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -476,6 +476,9 @@ struct logical_volume *find_lv(const struct volume_group *vg,
 			       const char *lv_name);
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name);
+/* Find crypto store in VG */
+struct crypto_store *find_crypto_store_in_vg(struct volume_group *vg,
+					     const char *cs_name);
 
 /* Find LV segment containing given LE */
 struct lv_segment *first_seg(const struct logical_volume *lv);
@@ -567,6 +570,12 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 
 /*
+ * Crypto functions
+ */
+struct crypto_store *alloc_cryptostore(struct dm_pool *mem, const char *name,
+				       struct crypto_store_type *cst);
+
+/*
 * Begin skeleton for external LVM library
 */
 struct device *pv_dev(const pv_t *pv);
-- 
1.5.6.5


