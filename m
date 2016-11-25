From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 14:04:08 +0000 (UTC)
Subject: master - cleanup: add missing WARNING into log_warn
Message-ID: <20161125140408.C9AAC607B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c10028dd8eb5d2302dfa588bbae034eb24d710cf
Commit:        c10028dd8eb5d2302dfa588bbae034eb24d710cf
Parent:        1a4f13eb6e4de75884f7950a5feeff90614b93cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 14:17:56 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:01:27 2016 +0100

cleanup: add missing WARNING into log_warn

---
 tools/toollib.c  |    6 +++---
 tools/vgreduce.c |    6 ++++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8c76291..9f399b8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -578,18 +578,18 @@ static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
 
 	pvname = pv_dev_name(pvl->pv);
 	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
-		log_warn("Physical volume %s not allocatable.", pvname);
+		log_warn("WARNING: Physical volume %s not allocatable.", pvname);
 		return 1;
 	}
 
 	if (allocatable_only && is_missing_pv(pvl->pv)) {
-		log_warn("Physical volume %s is missing.", pvname);
+		log_warn("WARNING: Physical volume %s is missing.", pvname);
 		return 1;
 	}
 
 	if (allocatable_only &&
 	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
-		log_warn("No free extents on physical volume \"%s\".", pvname);
+		log_warn("WARNING: No free extents on physical volume \"%s\".", pvname);
 		return 1;
 	}
 
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 42893df..e8479a8 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -67,7 +67,7 @@ static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg)
 		cmd->handles_missing_pvs = 1;
 		log_error("There are still partial LVs in VG %s.", vg->name);
 		log_error("To remove them unconditionally use: vgreduce --removemissing --force.");
-		log_warn("Proceeding to remove empty missing PVs.");
+		log_warn("WARNING: Proceeding to remove empty missing PVs.");
 	}
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
@@ -114,7 +114,9 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 
 			if (!lv_is_visible(lv))
 				continue;
-			log_warn("Removing partial LV %s.", lv->name);
+
+			log_warn("WARNING: Removing partial LV %s.", display_lvname(lv));
+
 			if (!lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0))
 				return_0;
 			goto restart;


