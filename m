From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:01 -0400
Subject: master - ability to keep track of bad mdas in lvmcache
Message-ID: <201906072108.x57L817S005205@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=650524b9559bb56339b281af52db9f4df91038ae
Commit:        650524b9559bb56339b281af52db9f4df91038ae
Parent:        aeafdc1f45a5963290a5bc3ea1661018b072d817
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 12:39:08 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

ability to keep track of bad mdas in lvmcache

mda's that cannot be processed by lvm because of
some corruption can be kept on a separate list.
These will be used for more advanced repair in a
subsequent commit.
---
 lib/cache/lvmcache.c    |   55 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmcache.h    |    8 ++++++
 lib/metadata/metadata.h |    3 +-
 3 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b62e5e2..a36e145 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -31,6 +31,7 @@ struct lvmcache_info {
 	struct dm_list mdas;	/* list head for metadata areas */
 	struct dm_list das;	/* list head for data areas */
 	struct dm_list bas;	/* list head for bootloader areas */
+	struct dm_list bad_mdas;/* list head for bad metadata areas */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label;
 	const struct format_type *fmt;
@@ -39,6 +40,8 @@ struct lvmcache_info {
 	uint32_t ext_version;   /* Extension version */
 	uint32_t ext_flags;	/* Extension flags */
 	uint32_t status;
+	bool mda1_bad;		/* label scan found bad metadata in mda1 */
+	bool mda2_bad;		/* label scan found bad metadata in mda2 */
 };
 
 /* One per VG */
@@ -175,6 +178,54 @@ static void _destroy_duplicate_device_list(struct dm_list *head)
 	dm_list_init(head);
 }
 
+bool lvmcache_has_bad_metadata(struct device *dev)
+{
+	struct lvmcache_info *info;
+
+	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
+		/* shouldn't happen */
+		log_error("No lvmcache info for checking bad metadata on %s", dev_name(dev));
+		return false;
+	}
+
+	if (info->mda1_bad || info->mda2_bad)
+		return true;
+	return false;
+}
+
+void lvmcache_save_bad_mda(struct lvmcache_info *info, struct metadata_area *mda)
+{
+	if (mda->mda_num == 1)
+		info->mda1_bad = true;
+	else if (mda->mda_num == 2)
+		info->mda2_bad = true;
+	dm_list_add(&info->bad_mdas, &mda->list);
+}
+
+void lvmcache_get_bad_mdas(struct cmd_context *cmd,
+			   const char *vgname, const char *vgid,
+                           struct dm_list *bad_mda_list)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+	struct mda_list *mdal;
+	struct metadata_area *mda, *mda2;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_error(INTERNAL_ERROR "lvmcache_get_bad_mdas no vginfo %s", vgname);
+		return;
+	}
+
+	dm_list_iterate_items(info, &vginfo->infos) {
+		dm_list_iterate_items_safe(mda, mda2, &info->bad_mdas) {
+			if (!(mdal = zalloc(sizeof(*mdal))))
+				continue;
+			mdal->mda = mda;
+			dm_list_add(bad_mda_list, &mdal->list);
+		}
+	}
+}
+
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
@@ -1945,6 +1996,10 @@ void lvmcache_del_mdas(struct lvmcache_info *info)
 	if (info->mdas.n)
 		del_mdas(&info->mdas);
 	dm_list_init(&info->mdas);
+
+	if (info->bad_mdas.n)
+		del_mdas(&info->bad_mdas);
+	dm_list_init(&info->bad_mdas);
 }
 
 void lvmcache_del_das(struct lvmcache_info *info)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 5e59b94..dd6730e 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -220,4 +220,12 @@ void lvmcache_save_metadata_size(uint64_t val);
 
 int dev_in_device_list(struct device *dev, struct dm_list *head);
 
+bool lvmcache_has_bad_metadata(struct device *dev);
+
+void lvmcache_save_bad_mda(struct lvmcache_info *info, struct metadata_area *mda);
+
+void lvmcache_get_bad_mdas(struct cmd_context *cmd,
+                           const char *vgname, const char *vgid,
+                           struct dm_list *bad_mda_list);
+
 #endif
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index d904aa6..6d158fe 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -185,6 +185,7 @@ struct metadata_area {
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
 	uint32_t status;
+	int mda_num;
 	uint32_t bad_fields; /* BAD_MDA_ flags are set to indicate errors found when reading */
 	uint32_t ignore_bad_fields; /* BAD_MDA_ flags are set to indicate errors to ignore */
 };
@@ -248,7 +249,7 @@ struct name_list {
 
 struct mda_list {
 	struct dm_list list;
-	struct device_area mda;
+	struct metadata_area *mda;
 };
 
 struct peg_list {


