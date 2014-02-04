From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Feb 2014 13:51:38 +0000 (UTC)
Subject: master - tests: update test
Message-ID: <20140204135138.0458B6107F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef557b8091ff67f38424d3f8413f3a543275b01d
Commit:        ef557b8091ff67f38424d3f8413f3a543275b01d
Parent:        324781953178ed9787257334a73d93e731add0c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 3 18:26:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 14:49:38 2014 +0100

tests: update test

Remove some unneeded traces and outputs.
---
 test/lib/aux.sh                         |    3 ++-
 test/shell/lvconvert-repair-dmeventd.sh |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2a882a2..3c02d40 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -52,6 +52,7 @@ prepare_clvmd() {
 
 prepare_dmeventd() {
 	if pgrep dmeventd ; then
+		rm -f debug.log
 		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
 		skip
 	fi
@@ -654,7 +655,7 @@ skip_if_raid456_replace_broken() {
 
 udev_wait() {
 	pgrep udev >/dev/null || return 0
-	which udevadm >/dev/null || return 0
+	which udevadm &>/dev/null || return 0
 	if test -n "$1" ; then
 		udevadm settle --exit-if-exists="$1" || true
 	else
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 55eee37..1604ecb 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -14,8 +14,8 @@
 which mkfs.ext2 || skip
 aux skip_if_mirror_recovery_broken
 
-aux prepare_vg 5
 aux prepare_dmeventd
+aux prepare_vg 5
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way


