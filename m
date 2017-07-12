From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Jul 2017 07:53:29 -0400
Subject: master - tests: properly check variables were defined
Message-ID: <201707121153.v6CBrTFe012176@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4b6df94b4a39335369c439eb3110a06649378e5
Commit:        c4b6df94b4a39335369c439eb3110a06649378e5
Parent:        1daa1cc3a98b8812912875773ad3be1b9b173c4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 13:51:16 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 13:51:16 2017 +0200

tests: properly check variables were defined

When test suite is installed some vars are not defined.
---
 test/api/pytest.sh   |    2 +-
 test/lib/inittest.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index ea53dbd..2581768 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -30,7 +30,7 @@ aux prepare_dmeventd
 # gdb -ex r --args python FULL_PATH/lvm2/test/api/python_lvm_unit.py -v TestLvm.test_lv_active_inactive
 
 #Locate the python binding library to use.
-if [[ -n "$abs_top_builddir" ]]; then
+if [[ -n "${abs_top_builddir+varset}" ]]; then
   python_lib=($(find "$abs_top_builddir" -name lvm.so))
   if [[ ${#python_lib[*]} -ne 1 ]]; then
     if [[ ${#python_lib[*]} -gt 1 ]]; then
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index c0f3e6b..f13b386 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -91,7 +91,7 @@ cd "$TESTDIR"
 mkdir lib
 
 # Setting up symlink from $i to $TESTDIR/lib
-test -n "$abs_top_builddir" && \
+test -n "${abs_top_builddir+varset}" && \
     find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
     -exec ln -s -t lib "{}" +
 find "$TESTOLDPWD/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \


