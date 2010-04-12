From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 12 Apr 2010 00:01:46 -0400
Subject: [PATCH] Use del_pvl_from_vgs() in vgreduce paths.
In-Reply-To: <1270598000-9771-5-git-send-email-dwysocha@redhat.com>
References: <1270598000-9771-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1271044906-3080-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Somehow these got missed in earlier patches.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    3 +--
 tools/vgreduce.c        |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a7b9e18..8e2faad 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -667,12 +667,11 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
 		goto bad;
 	}
 
-	vg->pv_count--;
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
+	del_pvl_from_vgs(vg, pvl);
 
 	/* add pv to the remove_pvs list */
-	dm_list_del(&pvl->list);
 	dm_list_add(&vg->removed_pvs, &pvl->list);
 
 	return 1;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 287db41..0cbe4b0 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -407,7 +407,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
 	if (pvl)
-		dm_list_del(&pvl->list);
+		del_pvl_from_vgs(vg, pvl);
 
 	pv->vg_name = vg->fid->fmt->orphan_vg_name;
 	pv->status = ALLOCATABLE_PV;
@@ -417,7 +417,6 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		goto bad;
 	}
 
-	vg->pv_count--;
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-- 
1.6.0.6


