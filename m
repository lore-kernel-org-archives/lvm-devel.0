From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 Sep 2016 13:55:55 +0000 (UTC)
Subject: master - cleanup: remove unused variables
Message-ID: <20160921135555.51E8960E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=094488ffab4837fa14069b81a15e0a6bdaca8a73
Commit:        094488ffab4837fa14069b81a15e0a6bdaca8a73
Parent:        926a56578185c7f22c9b3e9c36ff660ce6288c16
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 21 15:53:50 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 21 15:53:50 2016 +0200

cleanup: remove unused variables

---
 lib/metadata/lv.c |    1 -
 tools/lvconvert.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 60374dd..70036f9 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -988,7 +988,6 @@ int lv_mirror_image_in_sync(const struct logical_volume *lv)
 int lv_raid_image_in_sync(const struct logical_volume *lv)
 {
 	unsigned s;
-	dm_percent_t percent;
 	char *raid_health;
 	struct lv_segment *seg, *raid_seg = NULL;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4095101..3607247 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1826,7 +1826,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
-	dm_percent_t sync_percent;
 
 	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {


