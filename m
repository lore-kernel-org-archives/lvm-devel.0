From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:52 +0100
Subject: [PATCH 6/9] Add LCK_UNLOCK_FS and unlock_fs
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <4632763adba013fc1750a42bc4cd850027443575.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use new bit in LCK flags - LCK_UNLOCK_FS
And add new wrapper unlock_fs() around lock_vol for clustering.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/locking.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index cb1a55f..df33aec 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -94,6 +94,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
+#define LCK_UNLOCK_FS	0x00000400U	/* Operation waits to settle devices */
 
 /*
  * Additional lock bits for cluster communication via args[1]
@@ -125,6 +126,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_REVERT		(LCK_VG | LCK_READ  | LCK_CACHE | LCK_HOLD)
 
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
+#define LCK_VG_UNLOCK_FS       	(LCK_VG | LCK_UNLOCK_FS)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE)
@@ -169,6 +171,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
+#define unlock_fs(cmd)	\
+	lock_vol(cmd, VG_ORPHANS, LCK_VG_UNLOCK_FS)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
-- 
1.7.3.3


