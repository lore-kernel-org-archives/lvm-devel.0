From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 21 Aug 2015 20:27:10 +0000 (UTC)
Subject: master - tests: create/remove improvements for lvmlockd testing
Message-ID: <20150821202710.8D80660DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f27c9f6a44cb893b6653641b35295e129531bf8
Commit:        1f27c9f6a44cb893b6653641b35295e129531bf8
Parent:        d310e1f90720e5ba387efe7ba0d7cc6266d9f844
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 20 16:10:36 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 21 15:09:38 2015 -0500

tests: create/remove improvements for lvmlockd testing

---
 test/shell/dlm-remove.sh      |    4 ++++
 test/shell/sanlock-prepare.sh |    1 +
 test/shell/sanlock-remove.sh  |   15 +++++++++++++--
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/test/shell/dlm-remove.sh b/test/shell/dlm-remove.sh
index d7af46f..3120d7f 100644
--- a/test/shell/dlm-remove.sh
+++ b/test/shell/dlm-remove.sh
@@ -15,6 +15,10 @@ test_description='Remove the dlm test setup'
 
 [ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
 
+# FIXME: collect debug logs (only if a test failed?)
+# lvmlockctl -d > lvmlockd-debug.txt
+# dlm_tool dump > dlm-debug.txt
+
 systemctl stop dlm
 systemctl stop corosync
 killall lvmlockd
diff --git a/test/shell/sanlock-prepare.sh b/test/shell/sanlock-prepare.sh
index 401d6d7..c3a25bf 100644
--- a/test/shell/sanlock-prepare.sh
+++ b/test/shell/sanlock-prepare.sh
@@ -73,6 +73,7 @@ prepare_lvmlockd_sanlock() {
 
 GL_DEV="/dev/mapper/GL_DEV"
 GL_FILE="$PWD/gl_file.img"
+dmsetup remove GL_DEV || true
 rm -f "$GL_FILE"
 dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
 GL_LOOP=$(losetup -f "$GL_FILE" --show)
diff --git a/test/shell/sanlock-remove.sh b/test/shell/sanlock-remove.sh
index 47487d6..19a2602 100644
--- a/test/shell/sanlock-remove.sh
+++ b/test/shell/sanlock-remove.sh
@@ -15,14 +15,25 @@ test_description='Remove the sanlock test setup'
 
 [ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
 
+# FIMXME: get this to run after a test fails
+
 # Removes the VG with the global lock that was created by
 # the corresponding create script.
 
 vgremove --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' glvg
 
+# FIXME: collect debug logs (only if a test failed?)
+# lvmlockctl -d > lvmlockd-debug.txt
+# sanlock log_dump > sanlock-debug.txt
 
 killall lvmlockd
 killall sanlock
 
-dmsetup remove GL_DEV
-# dmsetup remove glvg-lvmlock
+killall -9 lvmlockd
+killall -9 sanlock
+
+# FIXME: dmsetup remove LVMTEST*-lvmlock
+
+dmsetup remove glvg-lvmlock || true
+dmsetup remove GL_DEV || true
+


