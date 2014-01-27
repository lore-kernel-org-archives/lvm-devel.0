From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 27 Jan 2014 11:14:55 +0000 (UTC)
Subject: master - locking: avoid dropping locks
Message-ID: <20140127111455.0962161740@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b73d21ba940804ebe91641343ee76f52d6a138e
Commit:        6b73d21ba940804ebe91641343ee76f52d6a138e
Parent:        f18ee04fab76a3d817e7be9da76a589700878830
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 27 12:11:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 27 12:13:29 2014 +0100

locking: avoid dropping locks

When lvm2 command forks, it calls reset_locking(),
which as an unwanted side effect unlinked lock file from filesystem.

Patch changes the behavior to just close locked file descriptor
in children - so the lock is being still properly hold in the parent.
---
 WHATS_NEW                   |    1 +
 lib/locking/file_locking.c  |   17 +++++++++++++----
 test/shell/lock-parallel.sh |   39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d674161..f56ad20 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix unwanted drop of hold flocks on forked children.
   Respect LVM_LVMETAD_PIDFILE env var for lvm command.
   Avoid exposing temporary devices when initializing thin pool volume.
   Fix test when checking target version for available thin features.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 1fa23b3..fb84c5b 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -44,6 +44,15 @@ static sig_t _oldhandler;
 static sigset_t _fullsigset, _intsigset;
 static volatile sig_atomic_t _handler_installed;
 
+/* Drop lock known to be shared with another file descriptor. */
+static void _drop_shared_flock(const char *file, int fd)
+{
+	log_debug_locking("_drop_shared_flock %s.", file);
+
+	if (close(fd) < 0)
+		log_sys_debug("close", file);
+}
+
 static void _undo_flock(const char *file, int fd)
 {
 	struct stat buf1, buf2;
@@ -74,9 +83,9 @@ static int _release_lock(const char *file, int unlock)
 				log_very_verbose("Unlocking %s", ll->res);
 				if (flock(ll->lf, LOCK_NB | LOCK_UN))
 					log_sys_debug("flock", ll->res);
-			}
-
-			_undo_flock(ll->res, ll->lf);
+				_undo_flock(ll->res, ll->lf);
+			} else
+				_drop_shared_flock(ll->res, ll->lf);
 
 			dm_free(ll->res);
 			dm_free(llh);
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
new file mode 100644
index 0000000..f8e72c3
--- /dev/null
+++ b/test/shell/lock-parallel.sh
@@ -0,0 +1,39 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test parallel use of lvm commands and check locks aren't dropped
+# RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1049296
+
+. lib/test
+
+aux prepare_vg
+test -e LOCAL_CLVMD && skip
+
+lvcreate -L10 -n $lv1 $vg
+lvcreate -l1 -n $lv2 $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+
+# Slowdown PV for resized LV
+aux delay_dev "$dev1" 40 40
+
+lvresize -L-5 -r $vg/$lv1 &
+
+# Let's wait till resize start
+sleep 2
+
+lvremove -f $vg/$lv2
+
+wait
+
+aux enable_dev "$dev1"
+
+# Check removed $lv2 does not reappear
+not check lv_exists $vg $lv2


