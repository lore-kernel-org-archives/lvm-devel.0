From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:14 +0000 (GMT)
Subject: master - lvmcache: add lvmcache_get_dev_mda
Message-ID: <20201022204314.70B903851C09@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3cdf0d881e63f16b8a29b26bbe3439798f44184
Commit:        b3cdf0d881e63f16b8a29b26bbe3439798f44184
Parent:        2c9bb676048fda86867df165aa297f7078dffc4b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 15 12:53:01 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

lvmcache: add lvmcache_get_dev_mda

for future patch
---
 lib/cache/lvmcache.c | 15 +++++++++++++++
 lib/cache/lvmcache.h |  2 ++
 2 files changed, 17 insertions(+)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ef0f4c391..4b2590c4d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -271,6 +271,21 @@ void lvmcache_get_mdas(struct cmd_context *cmd,
 	}
 }
 
+struct metadata_area *lvmcache_get_dev_mda(struct device *dev, int mda_num)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+
+	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
+		return NULL;
+
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (mda->mda_num == mda_num)
+			return mda;
+	}
+	return NULL;
+}
+
 static void _vginfo_detach_info(struct lvmcache_info *info)
 {
 	if (!dm_list_empty(&info->list)) {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 7a718cad8..fb4ab5562 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -220,4 +220,6 @@ void lvmcache_get_mdas(struct cmd_context *cmd,
 const char *dev_filtered_reason(struct device *dev);
 const char *devname_error_reason(const char *devname);
 
+struct metadata_area *lvmcache_get_dev_mda(struct device *dev, int mda_num);
+
 #endif


