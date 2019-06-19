From: David Teigland <teigland@sourceware.org>
Date: Wed, 19 Jun 2019 11:44:10 -0400
Subject: stable-2.02 - Revert "lvconvert: disable linear to mirror of active LV in cluster VG"
Message-ID: <201906191544.x5JFiA2N004703@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3a87a2c2e339328ea4d7448f43d5317806a6b24
Commit:        f3a87a2c2e339328ea4d7448f43d5317806a6b24
Parent:        1727df7c98b749be90a5790d3d9858a012f687f6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 19 10:40:37 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 19 10:40:37 2019 -0500

Revert "lvconvert: disable linear to mirror of active LV in cluster VG"

This reverts commit 8623e336513c6ac6fcb24aa7e2ef10b8a3a36c59.

The problem this was avoiding now seems to be fixed by
commit d6bce036155ae973c869bdce3ca5f824f933f599
  mirror: fix monitoring change
---
 tools/lvconvert.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fcbbd26..bc666c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -864,17 +864,6 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		/* FIXME Share code with lvcreate */
 
 		/*
-		 * Avoid bug 1711427 in which an exclusively active linear LV in a
-		 * clustered VG, when upconverted to a mirror, will mistakenly use
-		 * a userspace/cmirror log in _add_log() beause laopts.exclusive is
-		 * not set.
-		 */
-		if (vg_is_clustered(lv->vg) && lv_is_active(lv)) {
-			log_error("Cannot convert active LV to mirror in clustered VG.");
-			return 0;
-		}
-
-		/*
 		 * FIXME should we give not only pvh, but also all PVs
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.


