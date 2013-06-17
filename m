From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Jun 2013 07:38:14 +0000 (UTC)
Subject: master - cleanup: use struct assign
Message-ID: <20130617073814.5FA3260FDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f334b16d2d89c85d1bd46538c80729c490df7f9
Commit:        2f334b16d2d89c85d1bd46538c80729c490df7f9
Parent:        2636cae13991d6c9d51013c8702b13155577729a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 16 21:07:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 17 09:37:06 2013 +0200

cleanup: use struct assign

Simplier code with struct assign.
Drop unneeded zeroing of zallocated memory.
---
 lib/metadata/metadata.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c65144c..8a98aa6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -913,7 +913,10 @@ int vg_has_unknown_segments(const struct volume_group *vg)
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
 	struct volume_group *vg;
-	struct format_instance_ctx fic;
+	struct format_instance_ctx fic = {
+		.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS,
+		.context.vg_ref.vg_name = vg_name
+	};
 	struct format_instance *fid;
 	int consistent = 0;
 	uint32_t rc;
@@ -955,22 +958,12 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		goto_bad;
 
 	*vg->system_id = '\0';
-
 	vg->extent_size = DEFAULT_EXTENT_SIZE * 2;
-	vg->extent_count = 0;
-	vg->free_count = 0;
-
 	vg->max_lv = DEFAULT_MAX_LV;
 	vg->max_pv = DEFAULT_MAX_PV;
-
 	vg->alloc = DEFAULT_ALLOC_POLICY;
 	vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 
-	vg->pv_count = 0;
-
-	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = vg_name;
-	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;


