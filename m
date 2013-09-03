From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  3 Sep 2013 14:24:49 +0000 (UTC)
Subject: master - test: Skip tests involving mirror recovery on known bad kernels.
Message-ID: <20130903142449.B0B036113D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea1e8166d57c40a5406b68864e19056df6d2f103
Commit:        ea1e8166d57c40a5406b68864e19056df6d2f103
Parent:        6a5838a69ccd0b6eb2f6c69ec9a12de37c7ba73c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 3 15:49:14 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Sep 3 16:24:32 2013 +0200

test: Skip tests involving mirror recovery on known bad kernels.

---
 test/lib/aux.sh                                   |    4 ++++
 test/shell/lvconvert-repair-dmeventd.sh           |    1 +
 test/shell/lvconvert-repair-transient-dmeventd.sh |    1 +
 test/shell/lvconvert-repair-transient.sh          |    1 +
 4 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c9bb1fb..bca709a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -604,6 +604,10 @@ api() {
 	"$abs_top_builddir/test/api/wrapper" "$@" && rm -f debug.log
 }
 
+skip_if_mirror_recovery_broken() {
+        test `uname -r` = 3.3.4-5.fc17.i686 && skip
+}
+
 udev_wait() {
 	pgrep udev >/dev/null || return 0
 	which udevadm >/dev/null || return 0
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index b3ccca5..55eee37 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -12,6 +12,7 @@
 . lib/test
 
 which mkfs.ext2 || skip
+aux skip_if_mirror_recovery_broken
 
 aux prepare_vg 5
 aux prepare_dmeventd
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 51c95e1..699195a 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -11,6 +11,7 @@
 
 . lib/test
 
+aux skip_if_mirror_recovery_broken
 aux prepare_vg 5
 aux prepare_dmeventd
 
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 93eb803..28b06c6 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -11,6 +11,7 @@
 
 . lib/test
 
+aux skip_if_mirror_recovery_broken
 aux prepare_vg 5
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg


