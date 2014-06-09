From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  9 Jun 2014 00:35:28 +0000 (UTC)
Subject: master - test: Reflect that --sysinit only treats lvmetad specially with -aay (not -ay).
Message-ID: <20140609003528.B138A60DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bb1efe2fbcbd5702836e2c97e9aa3a1eed88847
Commit:        4bb1efe2fbcbd5702836e2c97e9aa3a1eed88847
Parent:        ee200ddfc376bbfb332439f64ced54ce450535dd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 23:37:08 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 23:37:08 2014 +0200

test: Reflect that --sysinit only treats lvmetad specially with -aay (not -ay).

---
 test/shell/lvmetad-override.sh |    2 +-
 test/shell/lvmetad-warning.sh  |    6 +++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index 8f6e641..fe11658 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -18,7 +18,7 @@ vgcreate $vg1 $dev1 $dev2
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 kill $(cat LOCAL_LVMETAD)
 lvchange -ay $vg1 2>&1 | grep "Failed to connect"
-lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+lvchange -aay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
 lvchange -ay $vg1 --config 'global { use_lvmetad = 0 }' 2>&1 | not grep "Failed to connect"
 aux lvmconf "global/use_lvmetad = 0"
 lvchange -ay $vg1 --config 'global { use_lvmetad = 1 }' 2>&1 | grep "Failed to connect"
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 8bb01d1..365f70f 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -16,12 +16,16 @@ aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2"
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
+
 kill $(cat LOCAL_LVMETAD)
 lvchange -ay $vg1 2>&1 | grep "Failed to connect"
-lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+lvchange -aay $vg1 --sysinit 2>&1 | tee sysinit.txt
+not grep "Failed to connect" sysinit.txt
+
 aux lvmconf 'global/use_lvmetad = 0'
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+
 aux prepare_lvmetad
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"


