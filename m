From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:14 -0400
Subject: master - lvmcache: add shorter way to delete dev info
Message-ID: <201804231352.w3NDqEml000376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1717d4cb178b88dc70bc14a11aba199b34931bb0
Commit:        1717d4cb178b88dc70bc14a11aba199b34931bb0
Parent:        570c6239eebf18e6884d350654274d3bc8f1c4f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 1 10:20:34 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

lvmcache: add shorter way to delete dev info

Don't make the caller look up the info first.
---
 lib/cache/lvmcache.c |    8 ++++++++
 lib/cache/lvmcache.h |    2 ++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 53254f4..6479080 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1608,6 +1608,14 @@ void lvmcache_del(struct lvmcache_info *info)
 	dm_free(info);
 }
 
+void lvmcache_del_dev(struct device *dev)
+{
+	struct lvmcache_info *info;
+
+	if ((info = lvmcache_info_from_pvid((const char *)dev->pvid, dev, 0)))
+		lvmcache_del(info);
+}
+
 /*
  * vginfo must be info->vginfo unless info is NULL (orphans)
  */
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 3967b29..4343060 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -59,6 +59,7 @@ struct lvmcache_vgsummary {
 	const char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
+	int zero_offset;
 };
 
 int lvmcache_init(void);
@@ -83,6 +84,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   uint32_t vgstatus);
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt);
 void lvmcache_del(struct lvmcache_info *info);
+void lvmcache_del_dev(struct device *dev);
 
 /* Update things */
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,


