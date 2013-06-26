From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:07 +0000 (UTC)
Subject: dev-peter-config-profiles - metadata: add support for storing profile name in metadata (during vgcreate/lvcreate)
Message-ID: <20130626145607.4252D6159C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ef90eba33fb8b5d646e422c1fd43d6da990d63e
Commit:        1ef90eba33fb8b5d646e422c1fd43d6da990d63e
Parent:        00255dc6d473f20364960fff2acda69c50697e1d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:32:09 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

metadata: add support for storing profile name in metadata (during vgcreate/lvcreate)

If "vgcreate/lvcreate --profile <profile_name>" is used, the profile
name is automatically stored in metadata for making it possible to
load it automatically next time the VG/LV is used.
---
 lib/format_text/export.c         |    7 +++++++
 lib/format_text/format-text.c    |    2 +-
 lib/metadata/lv_manip.c          |    3 +++
 lib/metadata/metadata-exported.h |    1 +
 tools/vgcreate.c                 |    3 +++
 5 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index b6aac45..73030e4 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -418,6 +418,10 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(vg->alloc));
 	}
+
+	if (vg->profile)
+		outf(f, "profile = \"%s\"", vg->profile->name);
+
 	outf(f, "metadata_copies = %u", vg->mda_copies);
 
 	return 1;
@@ -623,6 +627,9 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(lv->alloc));
 
+	if (lv->profile)
+		outf(f, "profile = \"%s\"", lv->profile->name);
+
 	switch (lv->read_ahead) {
 	case DM_READ_AHEAD_NONE:
 		outfc(f, "# None", "read_ahead = -1");
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1c940ed..3512ba6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2414,7 +2414,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
-			FMT_UNLIMITED_STRIPESIZE | FMT_BAS;
+			FMT_UNLIMITED_STRIPESIZE | FMT_BAS | FMT_CONFIG_PROFILE;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
 		log_error("Failed to allocate dir_list");
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c9af654..76660ae 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4651,6 +4651,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				   status, lp->alloc, vg)))
 		return_NULL;
 
+	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
+		lv->profile = vg->cmd->profile_params->global_profile;
+
 	if (lp->read_ahead != lv->read_ahead) {
 		log_verbose("Setting read ahead sectors");
 		lv->read_ahead = lp->read_ahead;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 10aea9e..3c5bfcf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -110,6 +110,7 @@
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 #define FMT_BAS			0x000000400U	/* Supports bootloader areas? */
+#define FMT_CONFIG_PROFILE	0x000000800U	/* Supports configuration profiles? */
 
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 9be9416..45f4c04 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -62,6 +62,9 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
+		vg->profile = vg->cmd->profile_params->global_profile;
+
 	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
 	    !vg_set_max_lv(vg, vp_new.max_lv) ||
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||


