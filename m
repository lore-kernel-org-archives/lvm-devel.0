From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:52 +0100
Subject: [PATCH 11/15] Add lvcreate crypto LV implementation.
In-Reply-To: <35fcbf3ab1527b121e3a8064a35eab8f7a7a2f1d.1232488181.git.mbroz@redhat.com>
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
	<35fcbf3ab1527b121e3a8064a35eab8f7a7a2f1d.1232488181.git.mbroz@redhat.com>
Message-ID: <11624519b513cc630635406dc8b35f380bb43a9f.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lcvreate now support two modes for creating encrypted LVs:

1) specify encryption directly
	--crypt KeyStoreType --cipher Cipher --keysize KeySize

e.g.

lvcreate -n LV -l 4 --crypt plain --cipher aes-xts-plain --keysize 256 VG

2) use another LV as template (IOW reuse its cryptostore)
	--crypt TemplateLogicalVolume[Path]

e.g.

lvcreate -n LV2 -l 4 --crypt LV VG

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/args.h     |    4 ++
 tools/commands.h |    9 ++-
 tools/lvcreate.c |  160 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 168 insertions(+), 5 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 8f026fc..a1347ea 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -57,6 +57,10 @@ arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 
+arg(crypt_ARG, '\0', "crypt", string_arg, 0)
+arg(cipher_ARG, '\0', "cipher", string_arg, 0)
+arg(keysize_ARG, '\0', "keysize", int_arg, 0)
+
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
 arg(allocation_ARG, '\0', "allocation", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 58c6156..aa5814c 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -132,6 +132,8 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[--crypt KeyStoreType --cipher Cipher --keysize KeySize]\n"
+   "\t[--crypt TemplateLogicalVolume[Path]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
@@ -163,9 +165,10 @@ xx(lvcreate,
    "\t[--version]\n"
    "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
-   addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
-   corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
+   addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, cipher_ARG,
+   contiguous_ARG, corelog_ARG, crypt_ARG, extents_ARG, keysize_ARG,
+   major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG,
+   nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
    test_ARG, type_ARG, zero_ARG)
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f17f876..e0f59be 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -26,6 +26,7 @@ struct lvcreate_params {
 	int minor;
 	int corelog;
 	int nosync;
+	int crypt;
 
 	char *origin;
 	const char *vg_name;
@@ -38,6 +39,12 @@ struct lvcreate_params {
 
 	uint32_t mirrors;
 
+	const char *crypt_handler;
+	const char *cipher;
+	uint32_t keysize;
+	struct crypto_store *cryptostore;
+	const char *crypt_template;
+
 	const struct segment_type *segtype;
 
 	/* size */
@@ -327,6 +334,46 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 	return 1;
 }
 
+static int _read_crypt_params(struct lvcreate_params *lp,
+			      struct cmd_context *cmd)
+{
+	char *ptr;
+
+	if (!arg_count(cmd, crypt_ARG))
+		return 1;
+
+	if (arg_count(cmd, cipher_ARG)) {
+		/*
+		 * Explicit cipher specification
+		*/
+		lp->crypt_handler = arg_value(cmd, crypt_ARG);
+			if (!lvm_get_keystore_handler(lp->crypt_handler))
+			return 0;
+
+		// FIXME: validate this somehow
+		lp->cipher = arg_value(cmd, cipher_ARG);
+		lp->keysize = arg_uint_value(cmd, keysize_ARG, 1);
+	} else {
+		/*
+		* Template LV specified - use its cryptstore
+		*/
+		lp->crypt_template = arg_value(cmd, crypt_ARG);
+		lp->crypt = 2;
+
+		if ((ptr = strrchr(lp->crypt_template, '/')))
+			lp->crypt_template = ptr + 1;
+
+		if (!validate_name(lp->crypt_template)) {
+			log_error("Logical volume crypto template "
+				  "\"%s\" is invalid",
+				  lp->lv_name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 			    int argc, char **argv)
 {
@@ -346,6 +393,9 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, stripes_ARG) && lp->stripes == 1)
 		log_print("Redundant stripes argument: default is 1");
 
+	if (arg_count(cmd, crypt_ARG))
+		lp->crypt = 1;
+
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp))
 		lp->snapshot = 1;
 
@@ -365,6 +415,12 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 		}
 	}
 
+	if (!lp->crypt && (arg_count(cmd, cipher_ARG) ||
+			   arg_count(cmd, keysize_ARG))) {
+		log_error("--cipher and --keysize requires --crypt too");
+		return 0;
+	}
+
 	if (lp->snapshot) {
 		if (arg_count(cmd, zero_ARG)) {
 			log_error("-Z is incompatible with snapshots");
@@ -429,7 +485,8 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, cmd) ||
 	    !_read_stripe_params(lp, cmd) ||
-	    !_read_mirror_params(lp, cmd))
+	    !_read_mirror_params(lp, cmd) ||
+	    !_read_crypt_params(lp, cmd))
 		return_0;
 
 	/*
@@ -511,6 +568,66 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 	return 1;
 }
 
+static int _lvcreate_cryptostore(struct cmd_context *cmd, struct volume_group *vg,
+				 struct lvcreate_params *lp)
+{
+	struct lv_segment *seg;
+	struct lv_list *lvl;
+
+	if (!(lp->segtype = get_segtype_from_string(cmd, "crypt"))) {
+		log_error("Failed to initialize crypt segment.");
+		return 0;
+	}
+
+	if (lp->crypt_template) {
+		/*
+		 * We have template LV, reuse its cryptostore
+		 */
+		lvl = find_lv_in_vg(vg, lp->crypt_template);
+		if (!lvl) {
+			log_error("Template LV %s not found.", lp->crypt_template);
+			return 0;
+		}
+
+		seg = first_seg(lvl->lv);
+
+		if (!seg || !seg->crypto_store) {
+			log_error("Template LV %s have no assigned cryptostore.",
+				  lp->crypt_template);
+			return 0;
+		}
+
+		if (!seg->crypto_store->type) {
+			log_error("Cannot use LV %s as template, "
+				  "key handler is not loaded.", lp->crypt_template);
+			return 0;
+		}
+
+		if (!lv_retrieve_password(lvl->lv)) {
+			log_error("Cannot use LV %s as template, "
+				  "master key is invalid.", lp->crypt_template);
+			return 0;
+		}
+
+		lp->cryptostore = seg->crypto_store;
+		lp->crypt_handler = seg->crypto_store->type->name;
+	} else {
+		/*
+		 * New cryptostore.is needed
+		 * FIXME: only cryptostores without physical segments supported now
+		 */
+		if (!(lp->cryptostore = vg_add_cryptostore(vg, NULL, lp->crypt_handler))) {
+			log_error("Failed to create cryptstore LV.");
+			return 0;
+		}
+
+		lp->cryptostore->cipher = lp->cipher;
+		lp->cryptostore->key_size = lp->keysize;
+	}
+
+	return 1;
+}
+
 static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvcreate_params *lp)
 {
@@ -634,6 +751,31 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 	status |= lp->permission | VISIBLE_LV;
 
+	if (lp->crypt) {
+		if (!(vg->fid->fmt->features & FMT_SEGMENTS)) {
+			log_error("Metadata does not support encryption.");
+			return 0;
+		}
+
+		if (vg_is_clustered(vg)) {
+			log_error("Clustered encrypted volumes are not yet supported.");
+			return 0;
+		}
+
+		if (lp->snapshot || lp->mirrors > 1) {
+			log_error("Combination of encryption and snapshots "
+				  "is not yet supported.");
+			return 0;
+		}
+
+		if (lp->stripes > 1) {
+			log_error("Striping is incompatible with encryption volume..");
+			return 0;
+		}
+
+		//FIXME: validate used cipher
+	}
+
 	if (lp->snapshot) {
 		if (!activation()) {
 			log_error("Can't create snapshot without using "
@@ -711,6 +853,9 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	if (!archive(vg))
 		return 0;
 
+	if (lp->crypt && !_lvcreate_cryptostore(cmd, vg, lp))
+		return 0;
+
 	if (lp->lv_name)
 		lv_name = lp->lv_name;
 	else {
@@ -771,6 +916,16 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		       1, lp->extents, NULL, 0u, 0u, pvh, lp->alloc))
 		return_0;
 
+	if (lp->crypt) {
+		if (!lv_add_cryptostore(lv, lp->cryptostore)) {
+			log_error("Cannot assign crypto store.");
+			stack;
+			goto revert_new_lv;
+		}
+		if (!lv_retrieve_password(lv))
+			goto revert_new_lv;
+	}
+
 	if (lp->mirrors > 1) {
 		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
 				    adjusted_mirror_region_size(
@@ -878,7 +1033,8 @@ deactivate_and_revert_new_lv:
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
+	if (!lv_remove_cryptostores(lv) || !lv_remove(lv) ||
+	    !vg_write(vg) || (backup(vg), !vg_commit(vg)))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	return 0;
-- 
1.5.6.5


