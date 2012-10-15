From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Oct 2012 12:10:07 +0000 (UTC)
Subject: master - test: detect compilation with readline
Message-ID: <20121015121007.72B53A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=faa9a520857ecae31ab6e8f880a040e1e1b5363a
Commit:        faa9a520857ecae31ab6e8f880a040e1e1b5363a
Parent:        2fc1fc3a93783fa715a0c833e12962194674b8b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 13:18:32 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:07:06 2012 +0200

test: detect compilation with readline

check lvm shell functionality only if compiled with readline.
---
 test/lib/aux.sh        |   14 ++++++++++----
 test/shell/covercmd.sh |   23 +++++++++++++++++++++--
 2 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9094562..7c0c189 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -532,11 +532,17 @@ target_at_least()
 
 have_thin()
 {
-    target_at_least dm-thin-pool "$@" || exit 1
-    test "$THIN" = shared || test "$THIN" = internal || exit 1
+	target_at_least dm-thin-pool "$@" || exit 1
+	test "$THIN" = shared || test "$THIN" = internal || exit 1
 
-# disable thin_check if not present in system
-    which thin_check || lvmconf 'global/thin_check_executable = ""'
+	# disable thin_check if not present in system
+	which thin_check || lvmconf 'global/thin_check_executable = ""'
+}
+
+# check if lvm shell is build-in  (needs readline)
+have_readline()
+{
+	echo version | lvm &>/dev/null
 }
 
 test -f DEVICES && devs=$(cat DEVICES)
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 0514468..12d9be1 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -27,6 +27,7 @@ pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 "$dev5"
 vgcreate -c n $vg $(cat DEVICES)
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 
+if aux have_readline; then
 # test *scan and *display tools
 cat <<EOF | lvm
 pvscan
@@ -45,6 +46,24 @@ EOF
 for i in h b s k m g t p e H B S K M G T P E; do
 	echo pvdisplay --units $i "$dev1"
 done | lvm
+else
+pvscan
+vgscan
+lvscan
+lvmdiskscan
+vgdisplay --units k $vg
+lvdisplay --units g $vg
+pvdisplay -c "$dev1"
+pvdisplay -s "$dev1"
+vgdisplay -c $vg
+vgdisplay -s $vg
+lvdisplay -c $vg
+
+for i in h b s k m g t p e H B S K M G T P E; do
+	pvdisplay --units $i "$dev1"
+done
+fi
+
 
 # test vgexport vgimport tools
 vgchange -an $vg
@@ -61,8 +80,8 @@ done
 
 for i in pr "p rw" an ay "-monitor y" "-monitor n" \
         -resync -refresh "-addtag MYTAG" "-deltag MYETAG"; do
-	echo lvchange -$i $vg/$lv
-done | lvm
+	lvchange -$i $vg/$lv
+done
 
 pvck "$dev1"
 vgck $vg


