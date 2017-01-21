From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 21 Jan 2017 18:30:24 +0000 (UTC)
Subject: master - tests: properly quote heredoc
Message-ID: <20170121183024.430DF60190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2fa90bf38461a5de63cd11ffcc01fb984c8193b
Commit:        e2fa90bf38461a5de63cd11ffcc01fb984c8193b
Parent:        1a2b88516bd213a912ba6c5133a977a5003f3a16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 21 19:21:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jan 21 19:28:06 2017 +0100

tests: properly quote heredoc

Prepend \$ for vars which should remain in script.
Also drop --lazy umount.
Move inittest call up, so mntdir and mntusedir have proper full path.
---
 test/shell/thin-autoumount-dmeventd.sh |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 363efe2..eacad0a 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -16,6 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
+. lib/inittest
+
 mntdir="${PREFIX}mnt with space"
 mntusedir="${PREFIX}mntuse"
 
@@ -32,8 +34,6 @@ is_lv_opened_()
 	test $(get lv_field "$1" lv_device_open --binary) = "1"
 }
 
-. lib/inittest
-
 #
 # Main
 #
@@ -48,15 +48,17 @@ aux lvmconf "dmeventd/thin_command = \"$PWD/testcmd.sh\""
 cat <<- EOF >testcmd.sh
 #!/bin/sh
 
-echo "Data $DMEVENTD_THIN_POOL_DATA"
-echo "Metadata $DMEVENTD_THIN_POOL_METADATA"
+echo "Data: \$DMEVENTD_THIN_POOL_DATA"
+echo "Metadata: \$DMEVENTD_THIN_POOL_METADATA"
 
-lvextend --use-policies $1 || {
-	umount --lazy "$mntdir"  || true
-	umount --lazy "$mntusedir" || true
+$TESTDIR/lib/lvextend --use-policies \$1 || {
+	umount "$mntdir"  || true
+	umount "$mntusedir" || true
 }
 EOF
 chmod +x testcmd.sh
+# Show prepared script
+cat testcmd.sh
 
 aux prepare_dmeventd
 


