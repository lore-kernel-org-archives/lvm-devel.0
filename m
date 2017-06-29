From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:42 -0400
Subject: master - tests: api updates
Message-ID: <201706292029.v5TKTgB4027000@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c613fa48ffc0b4b89beedb93612270b29cc41fb9
Commit:        c613fa48ffc0b4b89beedb93612270b29cc41fb9
Parent:        3d90c7fffc3c7e5fa0a02d829909c204fa0d6bfb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 21:51:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: api updates

---
 test/api/dbustest.sh |    6 ++++--
 test/api/pytest.sh   |   10 ++++++----
 test/api/vglist.sh   |    2 +-
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 681e399..5817e01 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -25,7 +25,9 @@ cp -v "$TESTOLDPWD/lib/lvmdbusd.profile" "$TESTDIR/etc/profile/"
 
 # Need to set this up so that the lvmdbusd service knows which
 # binary to be running, which should be the one we just built
-export LVM_BINARY=$(which lvm 2>/dev/null)
+LVM_BINARY=$(which lvm 2>/dev/null)
+export LVM_BINARY
+
 # skip if we don't have our own lvmetad...
 if test -z "${installed_testsuite+varset}"; then
 	(echo "$LVM_BINARY" | grep -q "$abs_builddir") || skip
@@ -33,4 +35,4 @@ fi
 
 aux prepare_lvmdbusd
 
-$TESTOLDPWD/dbus/lvmdbustest.py -v
+"$TESTOLDPWD/dbus/lvmdbustest.py" -v
diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 28a1cd0..e4e0994 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -30,8 +30,8 @@ aux prepare_dmeventd
 # gdb -ex r --args python FULL_PATH/lvm2/test/api/python_lvm_unit.py -v TestLvm.test_lv_active_inactive
 
 #Locate the python binding library to use.
-if [[ -n $abs_top_builddir ]]; then
-  python_lib=($(find $abs_top_builddir -name lvm.so))
+if [[ -n "$abs_top_builddir" ]]; then
+  python_lib=($(find "$abs_top_builddir" -name lvm.so))
   if [[ ${#python_lib[*]} -ne 1 ]]; then
     if [[ ${#python_lib[*]} -gt 1 ]]; then
       # Unable to test python bindings if multiple libraries found:
@@ -43,7 +43,8 @@ if [[ -n $abs_top_builddir ]]; then
     fi
   fi
 
-  export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
+  PYTHONPATH=$(dirname "${python_lib[*]}"):$PYTHONPATH
+  export PYTHONPATH
 elif rpm -q lvm2-python-libs &>/dev/null; then
   true
 else
@@ -54,7 +55,8 @@ fi
 aux prepare_pvs 6
 
 #Setup which devices the unit test can use.
-export PY_UNIT_PVS=$(cat DEVICES)
+PY_UNIT_PVS=$(cat DEVICES)
+export PY_UNIT_PVS
 
 #python_lvm_unit.py -v -f
 
diff --git a/test/api/vglist.sh b/test/api/vglist.sh
index c76a92b..b07cac9 100644
--- a/test/api/vglist.sh
+++ b/test/api/vglist.sh
@@ -14,4 +14,4 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_vg 2
-aux apitest vglist $vg `get vg_field $vg vg_uuid | sed -e s,-,,g`
+aux apitest vglist $vg "$(get vg_field $vg vg_uuid | sed -e s,-,,g)"


