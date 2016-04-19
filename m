From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:33 +0000 (UTC)
Subject: master - test: lvmetad-override
Message-ID: <20160419164933.6A184610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b1c0a4190082728de1be2f2d19c1ef46c7f2d5c
Commit:        6b1c0a4190082728de1be2f2d19c1ef46c7f2d5c
Parent:        c5cd5b4b696ae85727be8df1fa5b335134531cd6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 18 15:19:45 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 11:45:24 2016 -0500

test: lvmetad-override

---
 test/shell/lvmetad-override.sh |   32 +++++++++++++++++++++++++++-----
 1 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index 0e56904..cd005fc 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -18,12 +18,34 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2"
-lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
+lvcreate -an -l1 --zero n -n $lv1 $vg1
+
+lvchange -ay $vg1 2>&1 | tee out
+not grep "WARNING: Failed to connect" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
 kill $(< LOCAL_LVMETAD)
-lvchange -ay $vg1 2>&1 | grep "Failed to connect"
-lvchange -aay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
-lvchange -ay $vg1 --config 'global { use_lvmetad = 0 }' 2>&1 | not grep "Failed to connect"
+
+lvchange -ay $vg1 2>&1 | tee out
+grep "WARNING: Failed to connect" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
+lvchange -ay --config global/use_lvmetad=0 $vg1 2>&1 | tee out
+not grep "WARNING: Failed to connect" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
+
 aux lvmconf "global/use_lvmetad = 0"
-lvchange -ay $vg1 --config 'global { use_lvmetad = 1 }' 2>&1 | grep "Failed to connect"
+
+lvchange -ay --config global/use_lvmetad=1 $vg1 2>&1 | tee out
+grep "WARNING: Failed to connect" out
+check active $vg1 $lv1
+lvchange -an $vg1
+check inactive $vg1 $lv1
 
 vgremove -ff $vg1


