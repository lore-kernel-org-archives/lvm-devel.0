From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:50 +0100
Subject: [PATCH 09/15] Add encrypted LV manipulation functions.
In-Reply-To: <b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
	<0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
	<b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
Message-ID: <3d899235af519a0e471dc86df580a991371b91fd.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - add vg_validate code which checks that all
   - crypt segments has referenced crypto_store
   - cryptostores have special LV in this VG
   - existing crypto_store LVs are referenced

 - add reserved LV name "cryptostoreN" used for cryptostore LV

 - retrieve segment master key before activate and preload commands
 (and skip the table loading if we have no key for crypt segments)

 - add cryptostore LV add/remove functions.

crypto_store has reference counter
(increased during segment loading or new crypt segment allocation)

If the last segment is removed, automatically remove special
crypto_store LV too.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c          |    6 ++
 lib/crypt/lvm-crypto.h           |    2 +
 lib/metadata/crypt_manip.c       |  142 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv_manip.c          |    5 ++
 lib/metadata/merge.c             |   30 ++++++++
 lib/metadata/metadata-exported.h |    6 ++
 tools/toollib.c                  |    6 ++
 7 files changed, 197 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2bc1db7..0f13cbd 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -863,6 +863,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
+		if (!lv_retrieve_password(lv))
+			return 0;
+
 		if (!_lv_preload(lv_pre)) {
 			/* FIXME Revert preloading */
 			return_0;
@@ -1047,6 +1050,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
+	if (!lv_retrieve_password(lv))
+		return 0;
+
 	memlock_inc();
 	r = _lv_activate_lv(lv);
 	memlock_dec();
diff --git a/lib/crypt/lvm-crypto.h b/lib/crypt/lvm-crypto.h
index 6ed2d91..42004b7 100644
--- a/lib/crypt/lvm-crypto.h
+++ b/lib/crypt/lvm-crypto.h
@@ -118,4 +118,6 @@ struct device_area *first_crypto_area(struct crypto_store *cs);
 int seg_assign_crypto_store_areas(struct lv_segment *seg);
 int seg_assign_cryptostore(struct lv_segment *seg, const char *name,
                            struct crypto_store_type *cst);
+int lv_retrieve_password(struct logical_volume *lv);
+
 #endif
diff --git a/lib/metadata/crypt_manip.c b/lib/metadata/crypt_manip.c
index 59e40b9..ff5c3e2 100644
--- a/lib/metadata/crypt_manip.c
+++ b/lib/metadata/crypt_manip.c
@@ -105,6 +105,67 @@ int seg_assign_cryptostore(struct lv_segment *seg, const char *name,
 	return 1;
 }
 
+
+/*
+ * Set cryptostore for all LV segments
+ */
+int lv_add_cryptostore(struct logical_volume *lv, struct crypto_store *cs)
+{
+	struct lv_segment *seg;
+
+	if (!find_crypto_store_in_vg(lv->vg, cs->name))
+		return_0;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		seg->crypto_store = cs;
+		seg->crypto_store->ref++;
+	}
+
+	return 1;
+}
+
+static int remove_cryptostore(struct crypto_store *cs, struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+
+	lvl = find_lv_in_vg(lv->vg, cs->name);
+
+	/*
+	 * Explicit cryptostore LV remove (lv_remove_single() do the job)
+	 * But do not allow removing of used cryptostore
+	 */
+	if (lv == lvl->lv)
+		return cs->ref ? 0 : 1;
+
+	if (--cs->ref)
+		return 1;
+
+	log_verbose("Removing unused cryptostore %s", cs->name);
+	dm_list_del(&cs->list);
+
+	if (!lv_remove(lvl->lv)) {
+		log_error("Error cryptostore logical volume \"%s\"", lvl->lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Try to remove cryptostores in all LV segments
+ */
+int lv_remove_cryptostores(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg->crypto_store &&
+		    !remove_cryptostore(seg->crypto_store, lv))
+			return 0;
+
+	return 1;
+}
+
 struct crypto_store *find_crypto_store_in_vg(struct volume_group *vg,
 					     const char *cs_name)
 {
@@ -116,3 +177,84 @@ struct crypto_store *find_crypto_store_in_vg(struct volume_group *vg,
 
 	return NULL;
 }
+
+/*
+ * Allocate new cryptostore. If seg is specified use it,
+ * otherwise alloc new virtual segment.
+ *
+ * Caller must set paramaters if required (like cipher).
+ */
+struct crypto_store *vg_add_cryptostore(struct volume_group *vg,
+					struct lv_segment *seg,
+					const char *handler_name)
+{
+	struct crypto_store *cs;
+	struct crypto_store_type *cst;
+	struct segment_type *cs_segtype;
+	struct logical_volume *cs_lv;
+
+	if (!(cs_segtype = get_segtype_from_string(vg->cmd, "crypt-keystore"))) {
+		log_error("Failed to initialize crypt-keystore segment.");
+		return NULL;
+	}
+
+	if (!(cs_lv = lv_create_empty("cryptostore%d", NULL,
+				      LVM_READ, vg->alloc, 0, vg))) {
+		log_error("Failed to create cryptstore LV.");
+		return NULL;
+	}
+
+	if (seg) {
+		/* We have physical key store area */
+		dm_list_add(&cs_lv->segments, &seg->list);
+		seg->lv = cs_lv;
+		seg->segtype = cs_segtype;
+		cs_lv->le_count = 1;
+	} else {
+		/* Need to allocate virtual segment*/
+		if (!lv_add_virtual_segment(cs_lv, LVM_READ, 0, cs_segtype))
+			return_NULL;
+
+		seg = first_seg(cs_lv);
+	}
+
+	if (!(cst = lvm_get_keystore_handler(handler_name)))
+		return_0;
+
+	if (!(cs = alloc_cryptostore(vg->cmd->mem, cs_lv->name, cst)))
+		return_0;
+
+	cs->id = cs_lv->lvid.id[1];
+	seg->crypto_store = cs;
+	if (!seg_assign_crypto_store_areas(seg))
+		return_0;
+
+	dm_list_add(&vg->crypto_stores, &cs->list);
+
+	return cs;
+}
+
+static int _seg_retrieve_masterkey(struct lv_segment *seg)
+{
+	/*
+	 * Master Key is already cached
+	 */
+	if (lvm_masterkeys_query(&seg->crypto_store->id))
+		return 1;
+
+	return lvm_masterkeys_retrieve(seg->lv->name, seg->crypto_store);
+}
+
+int lv_retrieve_password(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg_is_encrypted(seg) &&
+		    !seg_is_keystore(seg) &&
+		    !_seg_retrieve_masterkey(seg))
+			return 0;
+	}
+
+	return 1;
+}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2c3fdf5..0cdda57 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2056,6 +2056,11 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 	}
 
+	if (!lv_remove_cryptostores(lv)) {
+		log_error("Error removing cryptostores for logical volume \"%s\"", lv->name);
+		return 0;
+	}
+
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
 	if (!lv_remove(lv)) {
 		log_error("Error releasing logical volume \"%s\"", lv->name);
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index f1d8b9a..403bfbe 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -129,6 +129,36 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			}
 		}
 
+		if (seg_is_encrypted(seg)) {
+			if (!seg->crypto_store) {
+				log_error("LV %s: segment %u is encrypted but have "
+					  "no assigned crypto store",
+					  lv->name, seg_count);
+				r = 0;
+			} else if (!find_crypto_store_in_vg(lv->vg,
+							    seg->crypto_store->name)) {
+				log_error("LV %s: segment %u is encrypted but have "
+					  "assigned nonexisting crypto store %s",
+					  lv->name, seg_count, seg->crypto_store->name);
+				r = 0;
+			}
+			if (seg->area_count > 1) {
+				log_error("LV %s: encrypted segment %u have %u areas, "
+					  "but only one area is supported.",
+					  lv->name, seg_count, seg->area_count);
+				r = 0;
+			}
+		}
+
+		if (seg_is_keystore(seg)) {
+			if (!seg->crypto_store->ref) {
+				log_error("LV %s: segment %u is keystore and "
+					  "is not referenced by any other LV.",
+					  lv->name, seg_count);
+				r = 0;
+			}
+		}
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_UNASSIGNED) {
 				log_error("LV %s: segment %u has unassigned "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2aa5a1b..9835308 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -575,6 +575,12 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 struct crypto_store *alloc_cryptostore(struct dm_pool *mem, const char *name,
 				       struct crypto_store_type *cst);
 
+struct crypto_store *vg_add_cryptostore(struct volume_group *vg,
+					struct lv_segment *seg,
+					const char *handler_name);
+int lv_remove_cryptostores(struct logical_volume *lv);
+int lv_add_cryptostore(struct logical_volume *lv, struct crypto_store *cs);
+
 /*
 * Begin skeleton for external LVM library
 */
diff --git a/tools/toollib.c b/tools/toollib.c
index a0494a1..bada05e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1160,6 +1160,12 @@ int apply_lvname_restrictions(const char *name)
 		return 0;
 	}
 
+	if (!strncmp(name, "cryptostore", 11)) {
+		log_error("Names starting \"cryptostore\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	if (strstr(name, "_mlog")) {
 		log_error("Names including \"_mlog\" are reserved. "
 			  "Please choose a different LV name.");
-- 
1.5.6.5


