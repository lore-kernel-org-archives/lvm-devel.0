From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Feb 2016 11:00:15 +0000 (UTC)
Subject: master - tests: indent
Message-ID: <20160212110015.80DD960262@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=337aa4ca8ef4e88c09567b47838e28688258ae44
Commit:        337aa4ca8ef4e88c09567b47838e28688258ae44
Parent:        0daf9d7ac5009d7c5642a6b1c7d8bb3fbc0c4382
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 12 11:59:42 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 12 11:59:42 2016 +0100

tests: indent

Better bash indention
---
 test/shell/thin-autoumount-dmeventd.sh |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 6b7c7c1..d4485b5 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -73,17 +73,20 @@ lvs -a $vg
 for i in $(seq 1 12) ; do
 	is_lv_opened_ "$vg/$lv1" || break
 	test $i -lt 12 || die "$mntdir should have been unmounted by dmeventd!"
-        sleep 1
+	sleep 1
 done
 
 is_lv_opened_ "$vg/$lv2" || \
-	die "$mntusedir is not mounted here (sleep already expired??) "
+	die "$mntusedir is not mounted here (sleep already expired??)"
 
 # Kill device holding process
 kill $PID_SLEEP
 wait
 
-is_lv_opened_ "$vg/$lv2" && \
-	{ mount; die "$mntusedir should have been unmounted by dmeventd!" }
+is_lv_opened_ "$vg/$lv2" && {
+	mount
+	die "$mntusedir should have been unmounted by dmeventd!"
+}
 
 vgremove -f $vg
+


