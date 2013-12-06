From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Dec 2013 09:09:38 +0000 (UTC)
Subject: master - tests: python test needs dmeventd
Message-ID: <20131206090938.2E898610ED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f460d6d9b5dcf0e13b70d4c1630a0f667849b8b9
Commit:        f460d6d9b5dcf0e13b70d4c1630a0f667849b8b9
Parent:        73a109d434ffb894cda9c7fc6720d1166a9d5bca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 6 10:07:22 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 6 10:08:34 2013 +0100

tests: python test needs dmeventd

Until lvm2app respects all lvm.conf setting,
this test require dmeventd.
---
 test/api/pytest.sh |   57 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 67e224c..55df9e8 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -13,18 +13,69 @@
 
 . lib/test
 
+#
+# TODO:
+# lvm2app is not yet capable to respect many lvm.conf options
+# since a lot of them is set in /tools/liblvmline
+# Until fixed - testing always runs with enabled monitoring
+# thus it needs dmeventd
+#
+aux prepare_dmeventd
+
 #If you change this change the unit test case too.
 aux prepare_pvs 6
 
 #Locate the python binding library to use.
-python_lib=`find $abs_top_builddir -name lvm.so`
+python_lib=$(find $abs_top_builddir -name lvm.so)
 
 # Unable to test python bindings if library not available
 test -z "$python_lib" && skip
 
-export PYTHONPATH=`dirname $python_lib`:$PYTHONPATH
+export PYTHONPATH=$(dirname $python_lib):$PYTHONPATH
 
 #Setup which devices the unit test can use.
 export PY_UNIT_PVS=$(cat DEVICES)
 
-python_lvm_unit.py -v -f
+#python_lvm_unit.py -v -f
+
+# Run individual tests for shorter error trace
+python_lvm_unit.py -v TestLvm.test_config_find_bool
+python_lvm_unit.py -v TestLvm.test_config_override
+python_lvm_unit.py -v TestLvm.test_config_reload
+python_lvm_unit.py -v TestLvm.test_dupe_lv_create
+python_lvm_unit.py -v TestLvm.test_get_set_extend_size
+python_lvm_unit.py -v TestLvm.test_lv_active_inactive
+python_lvm_unit.py -v TestLvm.test_lv_property
+python_lvm_unit.py -v TestLvm.test_lv_rename
+python_lvm_unit.py -v TestLvm.test_lv_resize
+python_lvm_unit.py -v TestLvm.test_lv_seg
+python_lvm_unit.py -v TestLvm.test_lv_size
+python_lvm_unit.py -v TestLvm.test_lv_snapshot
+python_lvm_unit.py -v TestLvm.test_lv_suspend
+python_lvm_unit.py -v TestLvm.test_lv_tags
+python_lvm_unit.py -v TestLvm.test_percent_to_float
+python_lvm_unit.py -v TestLvm.test_pv_create
+python_lvm_unit.py -v TestLvm.test_pv_empty_listing
+python_lvm_unit.py -v TestLvm.test_pv_getters
+python_lvm_unit.py -v TestLvm.test_pv_life_cycle
+python_lvm_unit.py -v TestLvm.test_pv_lookup_from_vg
+python_lvm_unit.py -v TestLvm.test_pv_property
+python_lvm_unit.py -v TestLvm.test_pv_resize
+python_lvm_unit.py -v TestLvm.test_pv_segs
+python_lvm_unit.py -v TestLvm.test_scan
+python_lvm_unit.py -v TestLvm.test_version
+python_lvm_unit.py -v TestLvm.test_vg_from_pv_lookups
+python_lvm_unit.py -v TestLvm.test_vg_getters
+python_lvm_unit.py -v TestLvm.test_vg_get_name
+python_lvm_unit.py -v TestLvm.test_vg_get_set_prop
+python_lvm_unit.py -v TestLvm.test_vg_get_uuid
+python_lvm_unit.py -v TestLvm.test_vg_lv_name_validate
+python_lvm_unit.py -v TestLvm.test_vg_names
+python_lvm_unit.py -v TestLvm.test_vg_reduce
+python_lvm_unit.py -v TestLvm.test_vg_remove_restore
+python_lvm_unit.py -v TestLvm.test_vg_tags
+python_lvm_unit.py -v TestLvm.test_vg_uuids
+
+# CHECKME: not for testing?
+#python_lvm_unit.py -v TestLvm.test_listing
+#python_lvm_unit.py -v TestLvm.test_pv_methods


