From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:58 +0000 (UTC)
Subject: master - tests: pytest update
Message-ID: <20141026173758.2F80360282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70616187b32ee890eae8e8607c2d247d16cd6787
Commit:        70616187b32ee890eae8e8607c2d247d16cd6787
Parent:        205e3ff88898848b6e5dcfde74bff829bd27bf83
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 07:27:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

tests: pytest update

---
 test/api/pytest.sh          |    3 +++
 test/api/python_lvm_unit.py |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 7b6085f..36f55fa 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -21,6 +21,9 @@
 # thus it needs dmeventd
 #
 
+# Example of using 'gdb' with python:
+# gdb -ex r --args python FULL_PATH/lvm2/test/api/python_lvm_unit.py -v TestLvm.test_lv_active_inactive
+
 #Locate the python binding library to use.
 python_lib=$(find $abs_top_builddir -name lvm.so)
 # Unable to test python bindings if library not available
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index ab2e86f..c338775 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -132,7 +132,7 @@ class TestLvm(unittest.TestCase):
 			vg.extend(d)
 
 		vg.createLvThinpool(pool_name, vg.getSize()/2, 0, 0,
-							lvm.THIN_DISCARDS_PASSDOWN, 1)
+				    lvm.THIN_DISCARDS_PASSDOWN, 1)
 		return vg
 
 	@staticmethod


