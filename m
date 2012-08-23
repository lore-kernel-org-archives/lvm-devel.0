From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:47 +0000 (UTC)
Subject: master - cleanup: use proper activation_change_t
Message-ID: <20120823124247.DE837A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=195fe0307526ffc8307842618a7eeb4a421cacf9
Commit:        195fe0307526ffc8307842618a7eeb4a421cacf9
Parent:        449c09201030cfb18baf8481430bc150e43f5f07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 21 15:49:23 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:38 2012 +0200

cleanup: use proper activation_change_t

---
 lib/cache/lvmetad.h              |    4 +++-
 lib/metadata/metadata-exported.h |    2 +-
 tools/pvscan.c                   |    3 ++-
 tools/vgchange.c                 |    3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 713c5a3..932a9f1 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -18,8 +18,10 @@
 struct volume_group;
 struct cmd_context;
 struct dm_config_tree;
+typedef enum activation_change activation_change_t;
 
-typedef int (*activation_handler) (struct volume_group *vg, int partial, int activate);
+typedef int (*activation_handler) (struct volume_group *vg, int partial,
+				   activation_change_t activate);
 
 #ifdef LVMETAD_SUPPORT
 /*
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f39f968..0658fad 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -571,7 +571,7 @@ const char *get_pool_discards_name(thin_discards_t discards);
 /*
  * Activation options
  */
-typedef enum {
+typedef enum activation_change {
 	CHANGE_AY = 0,  /* activate */
 	CHANGE_AN = 1,  /* deactivate */
 	CHANGE_AE = 2,  /* activate exclusively */
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a846322..6c634e3 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -97,7 +97,8 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 					   pv_pe_size(pv)));
 }
 
-static int _auto_activation_handler(struct volume_group *vg, int partial, int activate)
+static int _auto_activation_handler(struct volume_group *vg, int partial,
+				    activation_change_t activate)
 {
 	/* TODO: add support for partial and clustered VGs */
 	if (partial || vg_is_clustered(vg))
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 2013447..c59d58e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -512,7 +512,8 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (arg_count(cmd, activate_ARG)) {
-		if (!vgchange_activate(cmd, vg, arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+		if (!vgchange_activate(cmd, vg, (activation_change_t)
+				       arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
 			return ECMD_FAILED;
 	}
 


