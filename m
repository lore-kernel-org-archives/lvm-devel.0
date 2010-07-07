From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:37 +0200
Subject: [PATCH 03/22] Skip check missing rem.VGs for non-activate locks
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <96f03cef00342e69b9409b0f1b706afdb8aa62f5.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Skip call for checking whether this LV needs to locks some
more remote VGs (applies to replicator_dev devices).

The effect is, that deactivation of replicator-dev devices does
not require to take a lock for remote VGs, so avoids repeated invoke
of deactivate_lv.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/locking.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 488d194..dde1a08 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -136,7 +136,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	(find_replicator_vgs((lv)) ? \
+	((!((flags) & LCK_READ) || find_replicator_vgs((lv))) ? \
 		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
 		0)
 
-- 
1.7.1.1


