From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:14 +0000 (UTC)
Subject: master - dmsetup: add prefixes for all report types
Message-ID: <20150814210514.5D29760B3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc7a27bc3d8c14ba696cf6893708d2715918d564
Commit:        fc7a27bc3d8c14ba696cf6893708d2715918d564
Parent:        666722324f870c7ef0fb03acb043a00567067188
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 21:14:29 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

dmsetup: add prefixes for all report types

Add prefixes to all dmsetup report types to allow the 'group_all'
option to be effective:

  DR_NAME       name_
  DR_INFO       info_
  DR_DEPS       deps_
  DR_TREE       tree_
  DR_NAME       splitname_
---
 tools/dmsetup.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 7dd58b1..66364ac 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3877,11 +3877,11 @@ static void *_stats_get_obj(void *obj)
 }
 
 static const struct dm_report_object_type _report_types[] = {
-	{ DR_TASK, "Mapped Device Name", "", _task_get_obj },
-	{ DR_INFO, "Mapped Device Information", "", _info_get_obj },
-	{ DR_DEPS, "Mapped Device Relationship Information", "", _deps_get_obj },
-	{ DR_TREE, "Mapped Device Relationship Information", "", _tree_get_obj },
-	{ DR_NAME, "Mapped Device Name Components", "", _split_name_get_obj },
+	{ DR_TASK, "Mapped Device Name", "name_", _task_get_obj },
+	{ DR_INFO, "Mapped Device Information", "info_", _info_get_obj },
+	{ DR_DEPS, "Mapped Device Relationship Information", "deps_", _deps_get_obj },
+	{ DR_TREE, "Mapped Device Relationship Information", "tree_", _tree_get_obj },
+	{ DR_NAME, "Mapped Device Name Components", "splitname_", _split_name_get_obj },
 	{ DR_STATS, "Mapped Device Statistics","stats_", _stats_get_obj },
 	{ DR_STATS_META, "Mapped Device Statistics Region Information","stats_region_", _stats_get_obj },
 	{ 0, "", "", NULL }


