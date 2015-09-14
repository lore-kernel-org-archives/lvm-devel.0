From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Sep 2015 07:32:22 +0000 (UTC)
Subject: master - vgimporeclone: use correct cache dir path
Message-ID: <20150914073222.CB4BD611CE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e42ee69988fc770314a355e6acd417e00e0c9623
Commit:        e42ee69988fc770314a355e6acd417e00e0c9623
Parent:        226e7d7b3c30f083c422063ec107c50b3534ee0f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 09:24:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 09:31:26 2015 +0200

vgimporeclone: use correct cache dir path

Commit 00b36ef06acb15c82d7c9b37872753f02c638316 had a typo
and missed '{' for shell variable, thus command used slightly
different 'tmp' dir name for cache dir (with extra '}').

Such change was unnoticed until a recent fix in persistent
filter, lvm2 missed to update cache file when --config
was specified.

The result was, /tmp dir was accumulating snap.XXXXX} dirs when
running vgimportclose  script.
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c444c7..c661702 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Fix vgimportclone cache_dir path name (2.02.115).
   Swapping of LV identifiers handles more complex LVs.
   Use passed list of PVS when allocating space in lvconvert --thinpool.
   Disallow usage of --stripe and --stripesize when creating cache pool.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 388d14c..af8cf5c 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -1,7 +1,7 @@
 #!/bin/bash
 
 # Copyright (C) 2009 Chris Procter All rights reserved.
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -239,7 +239,7 @@ LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
 
 CMD_CONFIG_LINE="devices { \
                    scan = [ \"${TMP_LVM_SYSTEM_DIR}\" ] \
-                   cache_dir = \"$TMP_LVM_SYSTEM_DIR}/cache\"
+                   cache_dir = \"${TMP_LVM_SYSTEM_DIR}/cache\"
                    global_filter = [ \"a|.*|\" ] \
                    ${FILTER}
                  } \


