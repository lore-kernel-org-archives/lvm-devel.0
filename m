From: Milan Broz <mbroz@redhat.com>
Date: Thu, 17 Sep 2009 17:25:35 +0200
Subject: [PATCH 1/3] Return fail if lv_deactivate did not removed device from kernel.
Message-ID: <4AB254EF.2080008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Return fail if lv_deactivate did not removed device from kernel.

lv_deactivate now returns always success, because tree deactivation
functions (see dm_tree_deactivate_children) always returns success.

Because code should return failure in lv_deactivate at least,
fix it by checking for device existence after real deactivation call.

(After discussion this was preferred solution to dm tree function rewrite
which affects snapshots and mirrors.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index aa75e5b..724c1fe 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1017,6 +1017,8 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	memlock_dec();
 	fs_unlock();
 
+	if (!lv_info(cmd, lv, &info, 1, 0) || info.exists)
+		r = 0;
 out:
 	if (lv)
 		vg_release(lv->vg);



