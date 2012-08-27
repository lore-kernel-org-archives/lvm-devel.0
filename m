From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 27 Aug 2012 12:08:18 +0000 (UTC)
Subject: master - test: snapshot_extend_threshold -> snapshot_autoextend_threshold
Message-ID: <20120827120818.27CA122E8@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a70e98b05603bf8fc59929fd2709fb5d2b859e6
Commit:        2a70e98b05603bf8fc59929fd2709fb5d2b859e6
Parent:        c68c15757384e6cebd7667139661ab643eebbfbe
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 27 14:04:21 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 27 14:04:21 2012 +0200

test: snapshot_extend_threshold -> snapshot_autoextend_threshold

Missing the "auto" prefix in the config key name. The unknown
setting is silently ignored otherwise.
---
 test/shell/lvextend-snapshot-dmeventd.sh |    2 +-
 test/shell/lvextend-snapshot-policy.sh   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index fc3e30a..98bec19 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -12,7 +12,7 @@
 . lib/test
 
 extend() {
-	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
+	lvextend --use-policies --config "activation { snapshot_autoextend_threshold = $1 }" $vg/snap
 }
 
 write_() {
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index f5fdcbe..2f5d84b 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -14,7 +14,7 @@
 which mkfs.ext2 || skip
 
 extend() {
-	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
+	lvextend --use-policies --config "activation { snapshot_autoextend_threshold = $1 }" $vg/snap
 }
 
 write() {


