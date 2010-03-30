From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:15 +0200
Subject: [PATCH 14/22] Replicator: lock_vol update replicator LV
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <fd414a12bb907e4e8a18e0c35935d272dcb0023e.1269961680.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check for all needed VGs before calling lock_vol()

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/locking.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index e7f25b9..045300d 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -129,7 +129,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
+	(lv_replicator_sites_check_vg((lv)) ? \
+		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
+		0)
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
 #define unlock_and_release_vg(cmd, vg, vol) \
-- 
1.7.0.1


