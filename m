From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:21:56 +0100
Subject: [PATCH 2/6] Code move vg_mark_partial up in stack
In-Reply-To: <cover.1300828168.git.zkabelac@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
Message-ID: <8aefa95cff91ed17e8e436b0de68b6191a61a009.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's useful to keep the partial flag cached - so just move the call
for vg_mark_partil_lvs into lvmcache.c

This patch should not present any functional change.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c    |    7 +++++++
 lib/metadata/metadata.c |    5 -----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 037fc4a..d0de34f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -639,6 +639,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	struct volume_group *vg = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
+	int vg_missing;
 
 	if (!vgid || !(vginfo = vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
 		return NULL;
@@ -678,6 +679,12 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
 		goto_bad;
 
+	if ((vg_missing = vg_missing_pv_count(vg))) {
+		log_verbose("There are %d physical volumes missing.",
+			    vg_missing);
+		vg_mark_partial_lvs(vg);
+	}
+
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f4d4671..b6312a0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2819,11 +2819,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		else	/* Inconsistent but we can't repair it */
 			correct_vg->status &= ~INCONSISTENT_VG;
 
-		if (vg_missing_pv_count(correct_vg)) {
-			log_verbose("There are %d physical volumes missing.",
-				    vg_missing_pv_count(correct_vg));
-			vg_mark_partial_lvs(correct_vg);
-		}
 		return correct_vg;
 	} else {
 		free_vg(correct_vg);
-- 
1.7.4.1


