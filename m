From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 22:55:32 +0000 (UTC)
Subject: master - dmstats: change region fields prefix to 'region_'
Message-ID: <20150814225532.CF2F560793@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b487802a041a0848e927e3dfc3d71618b66ca42
Commit:        0b487802a041a0848e927e3dfc3d71618b66ca42
Parent:        f3891e90e32d0b76dc8c3ef2fb9bddbe09ffb846
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 23:53:42 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 23:53:42 2015 +0100

dmstats: change region fields prefix to 'region_'

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f90ce3e..9e72226 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3915,7 +3915,7 @@ static const struct dm_report_object_type _report_types[] = {
 	{ DR_TREE, "Mapped Device Relationship Information", "tree_", _tree_get_obj },
 	{ DR_NAME, "Mapped Device Name Components", "splitname_", _split_name_get_obj },
 	{ DR_STATS, "Mapped Device Statistics","stats_", _stats_get_obj },
-	{ DR_STATS_META, "Mapped Device Statistics Region Information","stats_region_", _stats_get_obj },
+	{ DR_STATS_META, "Mapped Device Statistics Region Information","region_", _stats_get_obj },
 	{ 0, "", "", NULL }
 };
 


