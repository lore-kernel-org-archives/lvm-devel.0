From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 21 Jan 2017 16:46:24 +0000 (UTC)
Subject: master - tests: implement umount in script
Message-ID: <20170121164624.C291A60797@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a2b88516bd213a912ba6c5133a977a5003f3a16
Commit:        1a2b88516bd213a912ba6c5133a977a5003f3a16
Parent:        47c11c7b1c364a2d2fd257aaa191816e146d3602
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 21 17:37:53 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jan 21 17:42:19 2017 +0100

tests: implement umount in script

Since dmeventd no longer umounts thin devices, such logic
needs to be implemented by external script.
Add some very simple one for the start.
---
 test/shell/thin-autoumount-dmeventd.sh |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 40dd75f..363efe2 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -42,6 +42,22 @@ export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
 aux have_thin 1 0 0 || skip
 
+aux lvmconf "dmeventd/thin_command = \"$PWD/testcmd.sh\""
+
+# Simple implementation of umount when lvextend fails
+cat <<- EOF >testcmd.sh
+#!/bin/sh
+
+echo "Data $DMEVENTD_THIN_POOL_DATA"
+echo "Metadata $DMEVENTD_THIN_POOL_METADATA"
+
+lvextend --use-policies $1 || {
+	umount --lazy "$mntdir"  || true
+	umount --lazy "$mntusedir" || true
+}
+EOF
+chmod +x testcmd.sh
+
 aux prepare_dmeventd
 
 # Use autoextend percent 0 - so extension fails and triggers umount...


