From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 18:59:40 +0000 (UTC)
Subject: master - raid: Detect whether or not kernel supports raid0.
Message-ID: <20150924185940.CF12060E94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=028715b0f07c0cb9740f8bd81e3d69a29c3341d2
Commit:        028715b0f07c0cb9740f8bd81e3d69a29c3341d2
Parent:        4a74e19f80958e0eafeb49ef7a346ba7421b5698
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Sep 24 19:52:22 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 19:59:29 2015 +0100

raid: Detect whether or not kernel supports raid0.

---
 lib/metadata/segtype.h |    3 +++
 lib/raid/raid.c        |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index a14f9d0..fd833cd 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -60,6 +60,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_FREE		"free"
 #define SEG_TYPE_NAME_ZERO		"zero"
 #define SEG_TYPE_NAME_RAID		"raid"
+#define SEG_TYPE_NAME_RAID0		"raid0"
 #define SEG_TYPE_NAME_RAID1		"raid1"
 #define SEG_TYPE_NAME_RAID10		"raid10"
 #define SEG_TYPE_NAME_RAID4		"raid4"
@@ -205,6 +206,8 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 					  const char *name);
 
 #define RAID_FEATURE_RAID10			(1U << 0) /* version 1.3 */
+#define RAID_FEATURE_RAID0			(1U << 1) /* version 1.7 */
+#define RAID_FEATURE_RESHAPING			(1U << 2) /* version 1.8 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 13b9b6e..df22b54 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -331,6 +331,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 		const char *feature;
 	} _features[] = {
 		{ 1, 3, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
+		{ 1, 7, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
 	};
 
 	static int _raid_checked = 0;


