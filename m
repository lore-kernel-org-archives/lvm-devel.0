From: David Teigland <teigland@sourceware.org>
Date: Fri, 4 Oct 2019 13:06:26 -0400
Subject: master - vgremove: remove internal lvmlock LV
Message-ID: <201910041706.x94H6Q0p004441@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6240c91882a98df9eceab0312eec893b7051765
Commit:        b6240c91882a98df9eceab0312eec893b7051765
Parent:        a22729a5577689d896ea13a82e6af7f7dde30412
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 4 12:01:30 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 4 12:01:30 2019 -0500

vgremove: remove internal lvmlock LV

If a VG is forcibly changed from lock_type sanlock to
lock_type none, the internal lvmlock LV is left behind.
If that LV is not removed before vgremove is run on the
VG, then an internal check will be triggered by the
hidden lvmlock LV.  So, check for and remove a left over
lvmlock LV during vgremove.
---
 lib/locking/lvmlockd.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 612de5d..bdd567d 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -374,6 +374,7 @@ static int _remove_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 	}
 
+	log_debug("sanlock lvmlock LV removed");
 	return 1;
 }
 
@@ -1028,6 +1029,13 @@ int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg,
 
 	switch (lock_type_num) {
 	case LOCK_TYPE_NONE:
+		/*
+		 * If a sanlock VG was forcibly changed to none,
+		 * the sanlock_lv may have been left behind.
+		 */
+		if (vg->sanlock_lv)
+			_remove_sanlock_lv(cmd, vg);
+		return 1;
 	case LOCK_TYPE_CLVM:
 		return 1;
 	case LOCK_TYPE_DLM:


