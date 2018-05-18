From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 May 2018 10:28:07 -0400
Subject: master - tests: pick either python2 or python3 .so
Message-ID: <201805181428.w4IES7kx012388@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bbdde808a9dcb55a9ffd092e931dff80814daa7
Commit:        3bbdde808a9dcb55a9ffd092e931dff80814daa7
Parent:        fbf64fe730ffa27ee94867017742174f270d3fa0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 18 16:16:40 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 18 16:25:44 2018 +0200

tests: pick either python2 or python3 .so

Use matching PYTHON library implementation.
---
 test/api/pytest.sh |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index bf31b39..ed9df5e 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -31,7 +31,11 @@ aux prepare_dmeventd
 
 #Locate the python binding library to use.
 if [[ -n "${abs_top_builddir+varset}" ]]; then
-  python_lib=($(find "$abs_top_builddir" -name lvm*.so))
+  # For python2 look for  lvm.so, python3 uses some lengthy names
+  case "$(head -1 $(which python_lvm_unit.py) )" in
+  *2) python_lib=($(find "$abs_top_builddir" -name lvm.so)) ;;
+  *) python_lib=($(find "$abs_top_builddir" -name lvm*gnu.so)) ;;
+  esac
   if [[ ${#python_lib[*]} -ne 1 ]]; then
     if [[ ${#python_lib[*]} -gt 1 ]]; then
       # Unable to test python bindings if multiple libraries found:
@@ -58,9 +62,9 @@ aux prepare_pvs 6
 PY_UNIT_PVS=$(cat DEVICES)
 export PY_UNIT_PVS
 
-python_lvm_unit.py -v -f TestLvm.test_lv_persistence
-exit
-#python_lvm_unit.py -v -f
+#When needed to run 1 single individual python test
+#python_lvm_unit.py -v -f TestLvm.test_lv_persistence
+#exit
 
 # Run individual tests for shorter error trace
 for i in \


