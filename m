From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Feb 2017 16:47:50 -0500
Subject: master - lvconvert: adjust reshaping check to target version
Message-ID: <201702282147.v1SLloB0022796@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce1e5b99915cf45530e25628f02537136045c938
Commit:        ce1e5b99915cf45530e25628f02537136045c938
Parent:        80a6de616a19e1be2e4125878ee904e5a1eeedf9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 28 22:46:25 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 28 22:46:25 2017 +0100

lvconvert: adjust reshaping check to target version

https://git.kernel.org/cgit/linux/kernel/git/device-mapper/linux-dm.git/commit/?h=dm-4.11&id=b08c6076782
sets the dm-raid target version to 1.10.1.

Adjust the condition to set RAID_RESHAPE_FEATURE to it.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/segtype.h |    2 +-
 lib/raid/raid.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index bea7141..a7a3857 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -286,7 +286,7 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 #define RAID_FEATURE_RAID0			(1U << 1) /* version 1.7 */
 #define RAID_FEATURE_RESHAPING			(1U << 2) /* version 1.8 */
 #define RAID_FEATURE_RAID4			(1U << 3) /* ! version 1.8 or 1.9.0 */
-#define RAID_FEATURE_RESHAPE			(1U << 4) /* version 1.10.2 */
+#define RAID_FEATURE_RESHAPE			(1U << 4) /* version 1.10.1 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 9ab2e6c..6815454 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -496,7 +496,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 					 SEG_TYPE_NAME_RAID4);
 
 		if (maj > 1 ||
-		    (maj == 1 && (min > 10 || (min == 10 && patchlevel >= 2))))
+		    (maj == 1 && (min > 10 || (min == 10 && patchlevel >= 1))))
 			_raid_attrs |= RAID_FEATURE_RESHAPE;
 	}
 


