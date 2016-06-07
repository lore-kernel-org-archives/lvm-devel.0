From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  7 Jun 2016 20:22:58 +0000 (UTC)
Subject: master - vgcreate, pvcreate, vgextend: don't use a device with duplicates
Message-ID: <20160607202258.9857360D29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86f92714574487cce6a9de785ba2ff93b23a98f7
Commit:        86f92714574487cce6a9de785ba2ff93b23a98f7
Parent:        199b7b55c21270d62ce35f32b16df200417dc41c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 6 15:39:51 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 7 15:21:07 2016 -0500

vgcreate, pvcreate, vgextend: don't use a device with duplicates

If duplicate orphan PVs exist, don't allow one of them to be
used for vgcreate/pvcreate/vgextend.
---
 lib/cache/lvmcache.c |   10 ++++++++++
 lib/cache/lvmcache.h |    2 ++
 tools/toollib.c      |    9 +++++++++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 87b25f1..9d89b80 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1519,6 +1519,16 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 	return dev->pvid;
 }
 
+int lvmcache_pvid_in_unchosen_duplicates(const char *pvid)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+		if (!strncmp(devl->dev->pvid, pvid, ID_LEN))
+			return 1;
+	}
+	return 0;
+}
 
 static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 5f85b03..4b8b942 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -213,4 +213,6 @@ int lvmcache_dev_is_unchosen_duplicate(struct device *dev);
 
 void lvmcache_remove_unchosen_duplicate(struct device *dev);
 
+int lvmcache_pvid_in_unchosen_duplicates(const char *pvid);
+
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index 7cde806..9353814 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3908,6 +3908,15 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	}
 
 	/*
+	 * Don't allow using a device with duplicates.
+	 */
+	if (lvmcache_pvid_in_unchosen_duplicates(pd->dev->pvid)) {
+		log_error("Cannot use device %s with duplicates.", pd->name);
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return 1;
+	}
+
+	/*
 	 * What kind of device is this: an orphan PV, an uninitialized/unused
 	 * device, a PV used in a VG.
 	 */


