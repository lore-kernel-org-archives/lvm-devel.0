From: David Teigland <teigland@sourceware.org>
Date: Tue, 1 May 2018 12:34:09 -0400
Subject: master - tests: update lvmetad-disabled to not use lvm1
Message-ID: <201805011634.w41GY9tx000411@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9687ee2a745d32ee4143759514e40c3f9fc7fbb6
Commit:        9687ee2a745d32ee4143759514e40c3f9fc7fbb6
Parent:        8dcc973bbb2372edaac8f4df4d8480225c04cfe5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 1 11:32:15 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 1 11:33:39 2018 -0500

tests: update lvmetad-disabled to not use lvm1

---
 test/shell/lvmetad-disabled.sh |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index cba73d6..0f180c7 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -24,11 +24,13 @@ test ! -e "$LVM_LVMETAD_PIDFILE"
 
 aux lvmconf "global/use_lvmetad = 0"
 
-pvcreate --metadatatype 1 "$dev1"
+pvcreate "$dev1"
 pvcreate "$dev2"
-vgcreate -M1 $vg1 "$dev1"
+vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev2"
 
+lvcreate -n $lv1 -l1 $vg1
+
 pvs 2>&1 | tee out
 grep "$dev1" out
 grep "$dev2" out
@@ -43,10 +45,21 @@ while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait f
 test -e "$LVM_LVMETAD_PIDFILE"
 cp "$LVM_LVMETAD_PIDFILE" LOCAL_LVMETAD
 
-pvscan --cache 2>&1 | tee out
+pvscan --cache
+pvs 2>&1 | tee out
+grep "$dev1" out
+grep "$dev2" out
+not grep "WARNING: Not using lvmetad" out
+
+# We don't care about the repair, and we know it's
+# not valid on this lv.  We are just running repair
+# because we know one side effect is to disable lvmetad.
+# FIXME: we should install lvmetactl so that we can
+# use that to directly disable lvmetad for tests like this.
+not lvconvert --repair $vg1/$lv1 2>&1 | tee out
 grep "WARNING: Disabling lvmetad cache" out
 
-pvs  2>&1 | tee out
+pvs  -vvvv 2>&1 | tee out
 grep "$dev1" out
 grep "$dev2" out
 grep "WARNING: Not using lvmetad" out
@@ -56,7 +69,8 @@ grep $vg1 out
 grep $vg2 out
 grep "WARNING: Not using lvmetad" out
 
-vgremove $vg1 2>&1 | tee out
+vgchange -an $vg1
+vgremove -y $vg1 2>&1 | tee out
 grep "WARNING: Not using lvmetad" out
 
 pvremove "$dev1" 2>&1 | tee out


