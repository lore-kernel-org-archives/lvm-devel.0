From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 15:34:15 +0000 (UTC)
Subject: master - tests: replace skip_if_mirror_recovery_broken
Message-ID: <20140317153415.0C46660E59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31b1d06dddbab131f85909315dcd1e2d3d6c4562
Commit:        31b1d06dddbab131f85909315dcd1e2d3d6c4562
Parent:        19fd6040c246b73dcdf8f522231e32e5889d4238
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 16:32:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 16:33:29 2014 +0100

tests: replace skip_if_mirror_recovery_broken

Use mirror_recovery_works instead with easier to follow logic.
---
 test/lib/aux.sh                                   |    7 ++++---
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-transient.sh          |    2 +-
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 65eb1e7..63896d1 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -641,9 +641,10 @@ api() {
 	"$abs_top_builddir/test/api/wrapper" "$@" && rm -f debug.log
 }
 
-skip_if_mirror_recovery_broken() {
-        if test `uname -r` = 3.3.4-5.fc17.i686; then skip; fi
-        if test `uname -r` = 3.3.4-5.fc17.x86_64; then skip; fi
+mirror_recovery_works() {
+	case $(uname -r) in
+	  3.3.4-5.fc17.i686|3.3.4-5.fc17.x86_64) return 1 ;;
+	esac
 }
 
 raid456_replace_works() {
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index a2d3ef8..472c812 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -12,7 +12,7 @@
 . lib/test
 
 which mkfs.ext2 || skip
-aux skip_if_mirror_recovery_broken
+aux mirror_recovery_works || skip
 
 aux prepare_dmeventd
 aux prepare_vg 5
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 6bd1442..1cda215 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux skip_if_mirror_recovery_broken
+aux mirror_recovery_works || skip
 aux prepare_vg 5
 aux prepare_dmeventd
 
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 3baa293..3614a69 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux skip_if_mirror_recovery_broken
+aux mirror_recovery_works || skip
 aux prepare_vg 5
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg


