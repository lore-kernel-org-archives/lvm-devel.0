From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Sep 2015 20:10:52 +0000 (UTC)
Subject: master - segtypes: Make constants ULL.
Message-ID: <20150922201052.270DF6030A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28aff5d240bd73ad0501504ed596819f2d4f058a
Commit:        28aff5d240bd73ad0501504ed596819f2d4f058a
Parent:        532b2d2d4e6817b8971665c2fe30821c7ec7dadd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 22 21:10:46 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 22 21:10:46 2015 +0100

segtypes: Make constants ULL.

---
 lib/metadata/segtype.h |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 010c8db..aa18224 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -28,25 +28,25 @@ struct dm_config_node;
 struct dev_manager;
 
 /* Feature flags */
-#define SEG_CAN_SPLIT		0x0000000000000001U
-#define SEG_AREAS_STRIPED	0x0000000000000002U
-#define SEG_AREAS_MIRRORED	0x0000000000000004U
-#define SEG_SNAPSHOT		0x0000000000000008U
-#define SEG_FORMAT1_SUPPORT	0x0000000000000010U
-#define SEG_VIRTUAL		0x0000000000000020U
-#define SEG_CANNOT_BE_ZEROED	0x0000000000000040U
-#define SEG_MONITORED		0x0000000000000080U
-#define SEG_REPLICATOR		0x0000000000000100U
-#define SEG_REPLICATOR_DEV	0x0000000000000200U
-#define SEG_RAID		0x0000000000000400U
-#define SEG_THIN_POOL		0x0000000000000800U
-#define SEG_THIN_VOLUME		0x0000000000001000U
-#define SEG_CACHE		0x0000000000002000U
-#define SEG_CACHE_POOL		0x0000000000004000U
-#define SEG_MIRROR		0x0000000000008000U
-#define SEG_ONLY_EXCLUSIVE	0x0000000000010000U /* In cluster only exlusive activation */
-#define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000U
-#define SEG_UNKNOWN		0x8000000000000000U
+#define SEG_CAN_SPLIT		0x0000000000000001ULL
+#define SEG_AREAS_STRIPED	0x0000000000000002ULL
+#define SEG_AREAS_MIRRORED	0x0000000000000004ULL
+#define SEG_SNAPSHOT		0x0000000000000008ULL
+#define SEG_FORMAT1_SUPPORT	0x0000000000000010ULL
+#define SEG_VIRTUAL		0x0000000000000020ULL
+#define SEG_CANNOT_BE_ZEROED	0x0000000000000040ULL
+#define SEG_MONITORED		0x0000000000000080ULL
+#define SEG_REPLICATOR		0x0000000000000100ULL
+#define SEG_REPLICATOR_DEV	0x0000000000000200ULL
+#define SEG_RAID		0x0000000000000400ULL
+#define SEG_THIN_POOL		0x0000000000000800ULL
+#define SEG_THIN_VOLUME		0x0000000000001000ULL
+#define SEG_CACHE		0x0000000000002000ULL
+#define SEG_CACHE_POOL		0x0000000000004000ULL
+#define SEG_MIRROR		0x0000000000008000ULL
+#define SEG_ONLY_EXCLUSIVE	0x0000000000010000ULL /* In cluster only exlusive activation */
+#define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000ULL
+#define SEG_UNKNOWN		0x8000000000000000ULL
 
 #define SEG_TYPE_NAME_LINEAR		"linear"
 #define SEG_TYPE_NAME_STRIPED		"striped"


