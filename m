From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:31 -0400
Subject: master - tests: better check for python libpath
Message-ID: <201805152005.w4FK5Vks001487@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99cd7108d3c589fb8ebbd636c98881cfee30e868
Commit:        99cd7108d3c589fb8ebbd636c98881cfee30e868
Parent:        f8745dc23e8c3e0b2850a0982d251f112d653179
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:57:29 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

tests: better check for python libpath

Find also python3 lvm.so name.

And ATM just run a single test, otherwise we get too many cores.
---
 test/api/pytest.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 2581768..bf31b39 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -31,7 +31,7 @@ aux prepare_dmeventd
 
 #Locate the python binding library to use.
 if [[ -n "${abs_top_builddir+varset}" ]]; then
-  python_lib=($(find "$abs_top_builddir" -name lvm.so))
+  python_lib=($(find "$abs_top_builddir" -name lvm*.so))
   if [[ ${#python_lib[*]} -ne 1 ]]; then
     if [[ ${#python_lib[*]} -gt 1 ]]; then
       # Unable to test python bindings if multiple libraries found:
@@ -58,6 +58,8 @@ aux prepare_pvs 6
 PY_UNIT_PVS=$(cat DEVICES)
 export PY_UNIT_PVS
 
+python_lvm_unit.py -v -f TestLvm.test_lv_persistence
+exit
 #python_lvm_unit.py -v -f
 
 # Run individual tests for shorter error trace


