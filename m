From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:29 +0000 (UTC)
Subject: master - test: update lvmetad-disabled
Message-ID: <20160419164929.2F68961005@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5722ed7e7b382f3bbb87c5e88c4a78e9ec4cf90
Commit:        a5722ed7e7b382f3bbb87c5e88c4a78e9ec4cf90
Parent:        c9cf85f606d14bcffdbdfaf19e0fa3a8e8b2a5d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 18 13:07:11 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 11:45:24 2016 -0500

test: update lvmetad-disabled

Update the check about lvmetad running but not used.

Also add tests related to the new lvmetad disabled state.
lvm1 metadata is used here to test the disabled state
because lvm1 metadata is the first condition using the
disabled state.
---
 test/shell/lvmetad-disabled.sh |   66 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 61 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 60cd2ff..e905ba7 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -15,18 +15,74 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux prepare_devs 2
+
 kill $(< LOCAL_LVMETAD)
 while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
 test ! -e "$LVM_LVMETAD_PIDFILE"
 
+aux lvmconf "global/use_lvmetad = 0"
+
+pvcreate --metadatatype 1 "$dev1"
+pvcreate "$dev2"
+vgcreate -M1 $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
+
+pvs 2>&1 | tee out
+grep "$dev1" out
+grep "$dev2" out
+
+vgs 2>&1 | tee out
+grep $vg1 out
+grep $vg2 out
+
+aux lvmconf "global/use_lvmetad = 1"
 lvmetad
 while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
 test -e "$LVM_LVMETAD_PIDFILE"
 cp "$LVM_LVMETAD_PIDFILE" LOCAL_LVMETAD
 
-pvs 2>&1 | not grep "lvmetad is running"
-aux lvmconf "global/use_lvmetad = 0"
-pvs 2>&1 | grep "lvmetad is running"
+not pvscan --cache 2>&1 | tee out
+grep "WARNING: Disabling lvmetad cache" out
+
+pvs  2>&1 | tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "WARNING: Not using lvmetad" out
+
+vgs  2>&1 | tee out
+grep $vg1 out
+grep $vg2 out
+grep "WARNING: Not using lvmetad" out
+
+vgremove $vg1 2>&1 | tee out
+grep "WARNING: Not using lvmetad" out
+
+pvremove "$dev1" 2>&1 | tee out
+grep "WARNING: Not using lvmetad" out
+
+pvscan --cache  2>&1 | tee out
+not grep "WARNING: Disabling lvmetad cache" out
+
+pvs 2>&1 | tee out
+not grep "$dev1" out
+grep "$dev2" out
+not grep "WARNING: Not using lvmetad" out
+
+vgs 2>&1 | tee out
+not grep $vg1 out
+grep $vg2 out
+not grep "WARNING: Not using lvmetad" out
+
+pvs --config 'global/use_lvmetad=0' 2>&1 | tee out
+not grep "$dev1" out
+grep "$dev2" out
+grep "WARNING: Not using lvmetad" out
+grep "use_lvmetad=0" out
+
+vgs --config 'global/use_lvmetad=0' 2>&1 | tee out
+not grep $vg1 out
+grep $vg2 out
+grep "WARNING: Not using lvmetad" out
+grep "use_lvmetad=0" out
 
-kill $(< "$LVM_LVMETAD_PIDFILE")
-not ls "$LVM_LVMETAD_PIDFILE"


