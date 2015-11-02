From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon,  2 Nov 2015 13:41:41 +0000 (UTC)
Subject: master - test: Run pytest with installed libs
Message-ID: <20151102134141.6705F61056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83d3cc76f3d4bc7b2be3b61cc1fd20f2cd5bbf85
Commit:        83d3cc76f3d4bc7b2be3b61cc1fd20f2cd5bbf85
Parent:        89574055f7a0d2e7dd10a781f5fbde4eeae1f637
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Nov 2 12:52:30 2015 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Nov 2 12:52:30 2015 +0100

test: Run pytest with installed libs

---
 test/api/pytest.sh |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 7ede416..8a8d084 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -30,15 +30,21 @@ aux prepare_dmeventd
 # gdb -ex r --args python FULL_PATH/lvm2/test/api/python_lvm_unit.py -v TestLvm.test_lv_active_inactive
 
 #Locate the python binding library to use.
-python_lib=$(find $abs_top_builddir -name lvm.so)
-# Unable to test python bindings if library not available
-test -n "$python_lib" || skip
+if [[ -n $abs_top_builddir ]]; then
+  python_lib=$(find $abs_top_builddir -name lvm.so)
+  # Unable to test python bindings if library not available
+  test -n "$python_lib" || skip "lvm2-python-libs not built"
+
+  export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
+elif rpm -q lvm2-python-libs &>/dev/null; then
+  true
+else
+  skip "lvm2-python-libs neither built nor installed"
+fi
 
 #If you change this change the unit test case too.
 aux prepare_pvs 6
 
-export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
-
 #Setup which devices the unit test can use.
 export PY_UNIT_PVS=$(cat DEVICES)
 


