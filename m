From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:23 -0400
Subject: master - toollib: support new command rules queries
Message-ID: <201807091335.w69DZNaK030788@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a821b88a439dd2d0f22e5bb1c4d6671ab517198b
Commit:        a821b88a439dd2d0f22e5bb1c4d6671ab517198b
Parent:        44c99a882299b4a6d6d675df3db5a6ef481fa2a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 2 10:50:41 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

toollib: support new command rules queries

Add: LV_vdo, LV_vdopool, LV_vdopooldata
---
 tools/lv_types.h |    3 +++
 tools/toollib.c  |   12 ++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/tools/lv_types.h b/tools/lv_types.h
index bd4666e..494776b 100644
--- a/tools/lv_types.h
+++ b/tools/lv_types.h
@@ -20,6 +20,9 @@ lvt(thin_LVT, "thin", NULL)
 lvt(thinpool_LVT, "thinpool", NULL)
 lvt(cache_LVT, "cache", NULL)
 lvt(cachepool_LVT, "cachepool", NULL)
+lvt(vdo_LVT, "vdo", NULL)
+lvt(vdopool_LVT, "vdopool", NULL)
+lvt(vdopooldata_LVT, "vdopooldata", NULL)
 lvt(mirror_LVT, "mirror", NULL)
 lvt(raid_LVT, "raid", NULL) /* any raid type */
 lvt(raid0_LVT, "raid0", NULL)
diff --git a/tools/toollib.c b/tools/toollib.c
index f0cf78e..62e1ecf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2544,6 +2544,12 @@ static int _lv_is_type(struct cmd_context *cmd, struct logical_volume *lv, int l
 		return lv_is_cache(lv);
 	case cachepool_LVT:
 		return lv_is_cache_pool(lv);
+	case vdo_LVT:
+		return lv_is_vdo(lv);
+	case vdopool_LVT:
+		return lv_is_vdo_pool(lv);
+	case vdopooldata_LVT:
+		return lv_is_vdo_pool_data(lv);
 	case mirror_LVT:
 		return lv_is_mirror(lv);
 	case raid_LVT:
@@ -2594,6 +2600,12 @@ int get_lvt_enum(struct logical_volume *lv)
 		return cache_LVT;
 	if (lv_is_cache_pool(lv))
 		return cachepool_LVT;
+	if (lv_is_vdo(lv))
+		return vdo_LVT;
+	if (lv_is_vdo_pool(lv))
+		return vdopool_LVT;
+	if (lv_is_vdo_pool_data(lv))
+		return vdopooldata_LVT;
 	if (lv_is_mirror(lv))
 		return mirror_LVT;
 	if (lv_is_raid(lv))


