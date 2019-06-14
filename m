From: David Teigland <teigland@sourceware.org>
Date: Fri, 14 Jun 2019 11:27:21 -0400
Subject: stable-2.02 - lvconvert: disable linear to mirror of active LV in cluster VG
Message-ID: <201906141527.x5EFRLJ9018079@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8623e336513c6ac6fcb24aa7e2ef10b8a3a36c59
Commit:        8623e336513c6ac6fcb24aa7e2ef10b8a3a36c59
Parent:        c31e6b0acad339ec3cdc0c8d7e0e01f8d816ed10
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 14 10:25:00 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 14 10:26:21 2019 -0500

lvconvert: disable linear to mirror of active LV in cluster VG

Avoid bug 1711427 in which an exclusively active linear LV in a
clustered VG, when upconverted to a mirror, will mistakenly use
a userspace/cmirror log in _add_log() beause laopts.exclusive is
not set.
---
 tools/lvconvert.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index bc666c0..fcbbd26 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -864,6 +864,17 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		/* FIXME Share code with lvcreate */
 
 		/*
+		 * Avoid bug 1711427 in which an exclusively active linear LV in a
+		 * clustered VG, when upconverted to a mirror, will mistakenly use
+		 * a userspace/cmirror log in _add_log() beause laopts.exclusive is
+		 * not set.
+		 */
+		if (vg_is_clustered(lv->vg) && lv_is_active(lv)) {
+			log_error("Cannot convert active LV to mirror in clustered VG.");
+			return 0;
+		}
+
+		/*
 		 * FIXME should we give not only pvh, but also all PVs
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.


