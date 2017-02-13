From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:52 +0000 (UTC)
Subject: master - commands: recognize raid variations
Message-ID: <20170213181052.1E98F60EFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2224b6a70158a820de2a9f1fd961a36b0188da51
Commit:        2224b6a70158a820de2a9f1fd961a36b0188da51
Parent:        c3faa5816d223b0a77a248aed9a88e73461268ce
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 6 11:51:06 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

commands: recognize raid variations

---
 tools/lv_types.h |    2 +-
 tools/toollib.c  |   16 ++++++----------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/tools/lv_types.h b/tools/lv_types.h
index 22d0522..bd4666e 100644
--- a/tools/lv_types.h
+++ b/tools/lv_types.h
@@ -21,7 +21,7 @@ lvt(thinpool_LVT, "thinpool", NULL)
 lvt(cache_LVT, "cache", NULL)
 lvt(cachepool_LVT, "cachepool", NULL)
 lvt(mirror_LVT, "mirror", NULL)
-lvt(raid_LVT, "raid", NULL)
+lvt(raid_LVT, "raid", NULL) /* any raid type */
 lvt(raid0_LVT, "raid0", NULL)
 lvt(raid1_LVT, "raid1", NULL)
 lvt(raid4_LVT, "raid4", NULL)
diff --git a/tools/toollib.c b/tools/toollib.c
index 3b47989..a539878 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2515,17 +2515,15 @@ static int _lv_is_type(struct cmd_context *cmd, struct logical_volume *lv, int l
 	case raid_LVT:
 		return lv_is_raid(lv);
 	case raid0_LVT:
-		return seg_is_raid0(seg);
+		return seg_is_any_raid0(seg);
 	case raid1_LVT:
 		return seg_is_raid1(seg);
 	case raid4_LVT:
 		return seg_is_raid4(seg);
-#if 0
 	case raid5_LVT:
-		return seg_is_raid5(seg);
+		return seg_is_any_raid5(seg);
 	case raid6_LVT:
-		return seg_is_raid6(seg);
-#endif
+		return seg_is_any_raid6(seg);
 	case raid10_LVT:
 		return seg_is_raid10(seg);
 	case error_LVT:
@@ -2566,18 +2564,16 @@ int get_lvt_enum(struct logical_volume *lv)
 		return mirror_LVT;
 	if (lv_is_raid(lv))
 		return raid_LVT;
-	if (seg_is_raid0(seg))
+	if (seg_is_any_raid0(seg))
 		return raid0_LVT;
 	if (seg_is_raid1(seg))
 		return raid1_LVT;
 	if (seg_is_raid4(seg))
 		return raid4_LVT;
-#if 0
-	if (seg_is_raid5(seg))
+	if (seg_is_any_raid5(seg))
 		return raid5_LVT;
-	if (seg_is_raid6(seg))
+	if (seg_is_any_raid6(seg))
 		return raid6_LVT;
-#endif
 	if (seg_is_raid10(seg))
 		return raid10_LVT;
 


