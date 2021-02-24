From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Feb 2021 11:10:39 +0000 (GMT)
Subject: stable-2.02 - lvconvert: improve support for metadata profiles
Message-ID: <20210224111039.4966D385800C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3babcb59123e61b0ecead3c8547a4c0ad607276
Commit:        f3babcb59123e61b0ecead3c8547a4c0ad607276
Parent:        e2b693fbe6139b0b991ea84a3011a74586b3b702
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 23:22:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 23:30:46 2021 +0100

lvconvert: improve support for metadata profiles

lvconvert can use thin-profile just like lvcreate.
(Added already upstream as part of VDO support).
---
 lib/metadata/lv_manip.c | 3 +++
 tools/lvmcmdline.c      | 1 +
 2 files changed, 4 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 11fab6d7b..0918780f1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7019,6 +7019,9 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	lv_where->le_count = layer_lv->le_count;
 	lv_where->size = (uint64_t) lv_where->le_count * lv_where->vg->extent_size;
 
+	if (lv_where->vg->fid->fmt->features & FMT_CONFIG_PROFILE)
+		lv_where->profile = lv_where->vg->cmd->profile_params->global_metadata_profile;
+
 	/*
 	 * recuresively rename sub LVs
 	 *   currently supported only for thin data layer
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 890aa0551..e82e4c661 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2573,6 +2573,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 		 * The --commandprofile is assumed otherwise.
 		 */
 		if (!strcmp(cmd->command->name, "lvcreate") ||
+		    !strcmp(cmd->command->name, "lvconvert") ||
 		    !strcmp(cmd->command->name, "vgcreate") ||
 		    !strcmp(cmd->command->name, "lvchange") ||
 		    !strcmp(cmd->command->name, "vgchange")) {


