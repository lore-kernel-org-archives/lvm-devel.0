From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 17 Dec 2018 13:29:33 -0500
Subject: master - lvcreate/lvconvert: optionally reenable mirrored mirror log for testing purposes only
Message-ID: <201812171829.wBHITXYD015824@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e82303fd6abc3ae43168f8032806c7c17d181a3e
Commit:        e82303fd6abc3ae43168f8032806c7c17d181a3e
Parent:        1f1d36f6a2b441fbf84e59f435bd5169459392b1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Dec 17 19:24:37 2018 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Dec 17 19:28:54 2018 +0100

lvcreate/lvconvert: optionally reenable mirrored mirror log for testing purposes only

This is a followup patch to commit edb72cb70cb8abd0acb92f07937715be2816d04a
to support related lvm2 test suite tests.

A 'global/support_mirrored_mirror_log' bool configuration variable gets
introduced allowing the creation of, or conversion to mirrored 'mirror'
logs if set.  The capability to create these in turn allows the rest of
the tests to perform activation of such existing LVs and their conversions
to disk/core 'mirror' logs.

Display a disclaimer warning if enabled that this is not for regular use.

Add definition of the enabled config option to respective test scripts.

Related: rhbz1643562
---
 conf/example.conf.in                   |   11 +++++++++++
 lib/config/config_settings.h           |   11 +++++++++++
 lib/metadata/mirror.c                  |   10 +++++++---
 test/shell/lvconvert-mirror.sh         |    2 ++
 test/shell/lvconvert-repair-replace.sh |    4 +++-
 test/shell/lvconvert-repair.sh         |    4 +++-
 test/shell/lvconvert-twostep.sh        |    4 +++-
 test/shell/lvcreate-operation.sh       |    4 +++-
 test/shell/snapshots-of-mirrors.sh     |    4 +++-
 test/shell/vgsplit-operation.sh        |    4 +++-
 10 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0204f4b..85465f5 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -904,6 +904,17 @@ global {
 	# 
 	mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
 
+	# Configuration option global/support_mirrored_mirror_log.
+	# Enable mirrored 'mirror' log type for testing.
+	#
+	# This type is deprecated to create or convert to but can
+	# be enabled to test that activation of existing mirrored
+	# logs and conversion to disk/core works.
+	#
+	# Not supported for regular operation!
+	#
+	support_mirrored_mirror_log = 0
+
 	# Configuration option global/raid10_segtype_default.
 	# The segment type used by the -i -m combination.
 	# The --type raid10|mirror option overrides this setting.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e473dd5..b0fcf8a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -960,6 +960,17 @@ cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECT
 	"    fashion in a cluster.\n"
 	"#\n")
 
+cfg(global_support_mirrored_mirror_log_CFG, "support_mirrored_mirror_log", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 3, 2), NULL, 0, NULL,
+	"Configuration option global/support_mirrored_mirror_log.\n"
+	"Enable mirrored 'mirror' log type for testing.\n"
+	"#\n"
+	"This type is deprecated to create or convert to but can\n"
+	"be enabled to test that activation of existing mirrored\n"
+	"logs and conversion to disk/core works.\n"
+	"#\n"
+	"Not supported for regular operation!\n"
+	"\n")
+
 cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), "@DEFAULT_RAID10_SEGTYPE@", 0, NULL,
 	"The segment type used by the -i -m combination.\n"
 	"The --type raid10|mirror option overrides this setting.\n"
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 8b20979..6950546 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008,2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1908,8 +1908,12 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (log_count > 1) {
-		log_err("Log type \"mirrored\" is DEPRECATED. Use RAID1 LV or disk log instead.");
-		return 0;
+		if (find_config_tree_bool(cmd, global_support_mirrored_mirror_log_CFG, NULL))
+			log_warn("Log type \"mirrored\" creation/conversion is not supported for regular operation!");
+		else {
+			log_err("Log type \"mirrored\" is DEPRECATED. Use RAID1 LV or disk log instead.");
+			return 0;
+		}
 	}
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 8f37645..7cf498d 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 aux prepare_pvs 5
 get_devs
 
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 1fe7965..3cd1fac 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008,2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 aux prepare_vg 6
 aux lvmconf 'allocation/maximise_cling = 0' \
 	    'allocation/mirror_logs_require_separate_pvs = 1'
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 5f7b851..ae8fa7e 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013,2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,6 +12,8 @@
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 recreate_vg_()
 {
 	vgremove -ff $vg
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index 44527f0..afc9d47 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010,2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 aux prepare_vg 4
 
 lvcreate -aey --type mirror -m 1 --mirrorlog disk --ignoremonitoring -L 1 -n mirror $vg
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 5faa39f..568af36 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008,2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,6 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 cleanup_lvs() {
 	lvremove -ff $vg
 	(dm_table | not grep $vg) || \
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index 48cadc5..f2f2943 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010,2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 aux prepare_vg 4
 
 lvcreate -aey --type mirror -m 1 -L 10M --nosync -n lv $vg
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index ab88866..eb24a58 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007,2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,6 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf "global/support_mirrored_mirror_log=1"
+
 COMM() {
 	LAST_TEST="$*"
 }


