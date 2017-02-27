From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 27 Feb 2017 15:42:55 -0500
Subject: master - lvconvert: limit libdm to maximum of 64 RAID devices
Message-ID: <201702272042.v1RKgtSB020335@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27384c52cf6a55ec7c8d64deecff2a81536193c7
Commit:        27384c52cf6a55ec7c8d64deecff2a81536193c7
Parent:        c41e99948819e896d9d06b4a8192ec7a63facf65
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Feb 27 21:42:15 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Feb 27 21:42:15 2017 +0100

lvconvert: limit libdm to maximum of 64 RAID devices

Commit 64a2fad5d6c6 raised the maximum number of RAID devices to 64.

Commit e2354ea344c2 introduced RAID_BITMAP_SIZE as 4 to have
256 bits (4 * 64 bit array members), thus changing the libdm API
unnecessarilly for the time being.

To not change the API, reduce RAID_BITMAP_SIZE to 1.
Remove an unneeded definition of it from libdm-common.h.

If we ever decide to raise past 64, we'll version the API.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 libdm/libdevmapper.h |   11 ++++++++++-
 libdm/libdm-common.h |    2 --
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 7fccac5..7136261 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1739,7 +1739,16 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
  */
 #define DM_CACHE_METADATA_MAX_SECTORS DM_THIN_METADATA_MAX_SECTORS
 
-#define	RAID_BITMAP_SIZE 4
+/*
+ * Define number of elements in rebuild and writemostly arrays
+ * 'of struct dm_tree_node_raid_params'.
+ *
+ * Set to one to keep the current libdm API!
+ *
+ * If we ever raise the maximum number of RAID devices past 64 thus
+ * changing the API, we have to version it for backwards API compatibility.
+ */
+#define	RAID_BITMAP_SIZE 1
 
 struct dm_tree_node_raid_params {
 	const char *raid_type;
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index a064db8..4dc1870 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -23,8 +23,6 @@
 #define DEV_NAME(dmt) (dmt->mangled_dev_name ? : dmt->dev_name)
 #define DEV_UUID(DMT) (dmt->mangled_uuid ? : dmt->uuid)
 
-#define RAID_BITMAP_SIZE	4
-
 int mangle_string(const char *str, const char *str_name, size_t len,
 		  char *buf, size_t buf_len, dm_string_mangling_t mode);
 


