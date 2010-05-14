From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:19:10 +0200
Subject: [PATCH 15/23] Replicator: lock_vol() finds missing VGs
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <764a82a3abc21e9cca55c4511d3a8fcaa6dccdf8.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Find and check for all needed VGs before calling lock_vol().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/locking.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 7a787ac..80e7b5b 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -129,7 +129,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
+	(find_replicator_vgs((lv)) ? \
+		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
+		0)
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
 #define unlock_and_release_vg(cmd, vg, vol) \
-- 
1.7.0.1


