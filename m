From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:23:04 +0000 (UTC)
Subject: master - test: move common code for thin init
Message-ID: <20121010192304.EF3C8AB3C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4eded9fd6686310ea653da889f40dbe8358f244
Commit:        d4eded9fd6686310ea653da889f40dbe8358f244
Parent:        b6512b10ae258b2d7e9b2cb6c5fff2edb2042c96
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 10 14:57:02 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 21:22:11 2012 +0200

test: move common code for thin init

---
 test/lib/aux.sh                  |    3 +++
 test/shell/discards-thin.sh      |    3 ---
 test/shell/lvconvert-thin.sh     |    3 ---
 test/shell/lvcreate-thin-snap.sh |    3 ---
 test/shell/lvcreate-thin.sh      |    3 ---
 5 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d972d10..f179e31 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -534,6 +534,9 @@ have_thin()
 {
     target_at_least dm-thin-pool "$@" || exit 1
     test "$THIN" = shared || test "$THIN" = internal || exit 1
+
+# disable thin_check if not present in system
+    which thin_check || lvmconf 'global/thin_check_executable = ""'
 }
 
 test -f DEVICES && devs=$(cat DEVICES)
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index ec3bd1f..4aa4293 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -22,9 +22,6 @@ aux have_thin 1 1 0 || skip
 
 aux prepare_pvs 2 64
 
-# disable thin_check if not present in system
-which thin_check || aux lvmconf 'global/thin_check_executable = ""'
-
 clustered=
 test -e LOCAL_CLVMD && clustered="--clustered y"
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index abaa620..32661cd 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -19,9 +19,6 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 4 64
 
-# disable thin_check if not present in system
-which thin_check || aux lvmconf 'global/thin_check_executable = ""'
-
 clustered=
 test -e LOCAL_CLVMD && clustered="--clustered y"
 
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 2ee8748..18846e3 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -30,9 +30,6 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 2 64
 
-# disable thin_check if not present in system
-which thin_check || aux lvmconf 'global/thin_check_executable = ""'
-
 clustered=
 test -e LOCAL_CLVMD && clustered="--clustered y"
 
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 7ba97ed..8ad552b 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -33,9 +33,6 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 2 64
 
-# disable thin_check if not present in system
-which thin_check || aux lvmconf 'global/thin_check_executable = ""'
-
 clustered=
 test -e LOCAL_CLVMD && clustered="--clustered y"
 


