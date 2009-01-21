From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:53 +0100
Subject: [PATCH 12/15] Add lvconcert crypt implementation.
In-Reply-To: <11624519b513cc630635406dc8b35f380bb43a9f.1232488181.git.mbroz@redhat.com>
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
	<11624519b513cc630635406dc8b35f380bb43a9f.1232488181.git.mbroz@redhat.com>
Message-ID: <8063c7b937ce3760c31028df5e6689d2bb35fde1.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvconvert --crypt KeyStoreType LogicalVolume[Path]

If the defined key handler contains support
for conversion (it implements scan function),
it converts linear volume into encrypted using
the first extent as keystore area.

Note, that there is currently not yet implemented
key management interface, so you lost access
to keystore for key management operation
after conversion.

You can activate volume using only keys defined
in the moment when conversion happened.

[basically this allows using LUKS keystore only now]

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/commands.h  |    8 +++-
 tools/lvconvert.c |  125 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 131 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index aa5814c..deb300b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -112,9 +112,13 @@ xx(lvconvert,
    "\t[-v|--verbose]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[--version]" "\n"
-   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
+   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n\n"
 
-   alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
+   "lvconvert "
+   "[--crypt KeyStoreType]\n"
+   "\tLogicalVolume[Path]]\n",
+
+   alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, crypt_ARG, interval_ARG,
    mirrorlog_ARG, mirrors_ARG, regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d1260f5..6723f5a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -15,10 +15,12 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lv_alloc.h"
+#include "metadata.h"
 
 struct lvconvert_params {
 	int snapshot;
 	int zero;
+	int crypt;
 
 	const char *origin;
 	const char *lv_name;
@@ -33,6 +35,9 @@ struct lvconvert_params {
 	uint32_t mirrors;
 	sign_t mirrors_sign;
 
+	const char *crypt_handler;
+	struct crypto_store_type *cs_type;
+
 	struct segment_type *segtype;
 
 	alloc_policy_t alloc;
@@ -123,6 +128,17 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
+	if (arg_count(cmd, crypt_ARG)) {
+		if (arg_count(cmd, snapshot_ARG) ||
+		    arg_count(cmd, mirrorlog_ARG) ||
+		    arg_count(cmd, mirrors_ARG)) {
+			log_error("--crypt argument cannot be mixed "
+				  "with mirrors of snapshots args");
+			return 0;
+		}
+		lp->crypt = 1;
+	}
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
@@ -159,6 +175,22 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 						 SEG_CANNOT_BE_ZEROED) ?
 						"n" : "y"), "n");
 
+	} else if (lp->crypt) { /* Convert to encrypted LV */
+
+		lp->crypt_handler = arg_str_value(cmd, crypt_ARG, NULL);
+		if (!(lp->cs_type = lvm_get_keystore_handler(lp->crypt_handler))) {
+			log_error("Unsuported crypt handler %s", lp->crypt_handler);
+			return 0;
+		}
+
+		if (!lp->cs_type->ops->scan) {
+			log_error("Key handler %s does not support conversion.",
+				  lp->cs_type->name);
+			return 0;
+		}
+
+		if (!(lp->segtype = get_segtype_from_string(cmd, "crypt")))
+			return_0;
 	} else {	/* Mirrors */
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with "
@@ -385,6 +417,15 @@ static int lvconvert_mirrors(struct cmd_context * cmd, struct logical_volume * l
 	struct logical_volume *original_lv;
 
 	seg = first_seg(lv);
+
+	if (seg_is_encrypted(seg)) {
+		log_error("Logical volume %s is encrypted, this operation is "
+			  "not supported because will store unencrypted data "
+			  "directly in new mirror log.",
+			  lv->name);
+		return 0;
+	}
+
 	existing_mirrors = lv_mirror_count(lv);
 
 	/* If called with no argument, try collapsing the resync layers */
@@ -685,6 +726,85 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	return 1;
 }
 
+static int lvconvert_crypt(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   struct lvconvert_params *lp)
+{
+	struct lv_segment *seg, *cs_seg;
+	struct crypto_store *cs;
+
+	/*
+	 * Conversion is supporetd only if keystore is in first extent. 
+	 */
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg_is_encrypted(seg)) {
+			log_error("Logical volume %s already contains encrypted "
+				  "segments.", lv->name);
+			return 0;
+		}
+		if (!seg_is_striped(seg) || seg->area_count > 1) {
+			log_error("Only plain linear volumes can be converted "
+				  "(no mirrors, stripes).");
+			return 0;
+		}
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Couldn't deactivate LV %s.", lv->name);
+		return 0;
+	}
+
+	/* Split keystore area */
+	if (!lv_split_segment(lv, 1)) {
+		log_error("Cannot split keystore from LV.");
+		return 0;
+	}
+
+	/*
+	 * Detach segment from LV
+	 */
+	cs_seg = first_seg(lv);
+	dm_list_del(&cs_seg->list);
+	dm_list_iterate_items(seg, &lv->segments) {
+		seg->segtype = lp->segtype;
+		seg->le--;
+	}
+	lv->le_count--;
+
+	if (!(cs = vg_add_cryptostore(lv->vg, cs_seg, lp->crypt_handler))) {
+		log_error("Failed to create cryptstore LV.");
+		return 0;
+	}
+
+	/*
+	 * Scan if the segment really contains compatible keystore header
+	 */
+	if (!cs->type->ops->scan(first_crypto_area(cs))) {
+		log_error("There is no compatible keystore area on LV %s.",
+			  lv->name);
+		return 0;
+	}
+
+	/*
+	 * Attach segment to cryptostore LV
+	 */
+	if (!lv_add_cryptostore(lv, cs)) {
+		log_error("Cannot change cryptostore to %s", lv->name);
+		return 0;
+	}
+
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!vg_commit(lv->vg))
+		return_0;
+
+	log_print("Logical volume %s was imported as encrypted.", lv->name);
+
+	return 1;
+}
+
 static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			    void *handle)
 {
@@ -721,6 +841,11 @@ static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_FAILED;
 		if (!lvconvert_snapshot(cmd, lv, lp))
 			return ECMD_FAILED;
+	} else if (lp->crypt) {
+		if (!archive(lv->vg))
+			return ECMD_FAILED;
+		if (!lvconvert_crypt(cmd, lv, lp))
+			return ECMD_FAILED;
 	} else if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
-- 
1.5.6.5


