From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:35 +0000 (UTC)
Subject: master - tests: thin_restore not needed
Message-ID: <20150518105235.A1DC861057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=caaca15854440c1781ecde06f3f8e3ecc6c728ca
Commit:        caaca15854440c1781ecde06f3f8e3ecc6c728ca
Parent:        62ac80c8fad09fb14f27d56663a5377948e20fce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 10:14:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:45:42 2015 +0200

tests: thin_restore  not needed

Few more test which could live without thin_restore.
---
 test/api/thin_percent.sh              |    2 ++
 test/shell/lvconvert-thin-external.sh |    2 ++
 test/shell/lvconvert-thin-raid.sh     |    2 ++
 test/shell/lvconvert-thin.sh          |    2 ++
 4 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index f93bd15..fd64e3b 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -11,6 +11,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 aux have_thin 1 0 0 || skip
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index b688d3a..eba9e36 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -12,6 +12,8 @@
 
 # Test conversion to thin external origin
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 8b4052c..bd554b2 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index b833362..8270c0e 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
 . lib/inittest
 
 test -e LOCAL_LVMPOLLD && skip


