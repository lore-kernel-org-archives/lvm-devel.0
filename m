From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:30 +0000 (UTC)
Subject: master - tests: drop DEBUG log after success
Message-ID: <20150422092030.A299460B69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3216a9a8195eb25e369781a4068015ef7c061845
Commit:        3216a9a8195eb25e369781a4068015ef7c061845
Parent:        14c3f9603e5bcb83c91aff4ed162152dfa1a695e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 10:55:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 10:55:37 2015 +0200

tests: drop DEBUG log after success

At this moment LVM_LOG_FILE_EPOCH with
LVM_EXPECTED_EXIT_STATUS  properly deletes debug logs
only for real commands - support for lvm2 API does not yet
exists
---
 test/api/pytest.sh |   81 +++++++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 38 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 00ab051..3b7c5b6 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -45,43 +45,48 @@ export PY_UNIT_PVS=$(cat DEVICES)
 #python_lvm_unit.py -v -f
 
 # Run individual tests for shorter error trace
-python_lvm_unit.py -v TestLvm.test_lv_persistence
-python_lvm_unit.py -v TestLvm.test_config_find_bool
-python_lvm_unit.py -v TestLvm.test_config_override
-python_lvm_unit.py -v TestLvm.test_config_reload
-python_lvm_unit.py -v TestLvm.test_dupe_lv_create
-python_lvm_unit.py -v TestLvm.test_get_set_extend_size
-python_lvm_unit.py -v TestLvm.test_lv_active_inactive
-python_lvm_unit.py -v TestLvm.test_lv_property
-python_lvm_unit.py -v TestLvm.test_lv_rename
-python_lvm_unit.py -v TestLvm.test_lv_resize
-python_lvm_unit.py -v TestLvm.test_lv_seg
-python_lvm_unit.py -v TestLvm.test_lv_size
-python_lvm_unit.py -v TestLvm.test_lv_snapshot
-python_lvm_unit.py -v TestLvm.test_lv_suspend
-python_lvm_unit.py -v TestLvm.test_lv_tags
-python_lvm_unit.py -v TestLvm.test_percent_to_float
-python_lvm_unit.py -v TestLvm.test_pv_create
-python_lvm_unit.py -v TestLvm.test_pv_empty_listing
-python_lvm_unit.py -v TestLvm.test_pv_getters
-python_lvm_unit.py -v TestLvm.test_pv_life_cycle
-python_lvm_unit.py -v TestLvm.test_pv_lookup_from_vg
-python_lvm_unit.py -v TestLvm.test_pv_property
-python_lvm_unit.py -v TestLvm.test_pv_resize
-python_lvm_unit.py -v TestLvm.test_pv_segs
-python_lvm_unit.py -v TestLvm.test_scan
-python_lvm_unit.py -v TestLvm.test_version
-python_lvm_unit.py -v TestLvm.test_vg_from_pv_lookups
-python_lvm_unit.py -v TestLvm.test_vg_getters
-python_lvm_unit.py -v TestLvm.test_vg_get_name
-python_lvm_unit.py -v TestLvm.test_vg_get_set_prop
-python_lvm_unit.py -v TestLvm.test_vg_get_uuid
-python_lvm_unit.py -v TestLvm.test_vg_lv_name_validate
-python_lvm_unit.py -v TestLvm.test_vg_names
-python_lvm_unit.py -v TestLvm.test_vg_reduce
-python_lvm_unit.py -v TestLvm.test_vg_remove_restore
-python_lvm_unit.py -v TestLvm.test_vg_tags
-python_lvm_unit.py -v TestLvm.test_vg_uuids
+for i in \
+ lv_persistence \
+ config_find_bool \
+ config_override \
+ config_reload  \
+ dupe_lv_create \
+ get_set_extend_size \
+ lv_active_inactive \
+ lv_property \
+ lv_rename \
+ lv_resize \
+ lv_seg \
+ lv_size \
+ lv_snapshot \
+ lv_suspend \
+ lv_tags \
+ percent_to_float \
+ pv_create \
+ pv_empty_listing \
+ pv_getters \
+ pv_life_cycle \
+ pv_lookup_from_vg \
+ pv_property \
+ pv_resize \
+ pv_segs \
+ scan \
+ version \
+ vg_from_pv_lookups \
+ vg_getters \
+ vg_get_name \
+ vg_get_set_prop \
+ vg_get_uuid \
+ vg_lv_name_validate \
+ vg_names \
+ vg_reduce \
+ vg_remove_restore \
+ vg_tags \
+ vg_uuids
+do
+	python_lvm_unit.py -v TestLvm.test_$i
+	rm -f debug.log_DEBUG*
+done
 
 # CHECKME: not for testing?
 #python_lvm_unit.py -v TestLvm.test_listing


