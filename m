From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:32 -0400
Subject: master - tests: use bash
Message-ID: <201707101232.v6ACWWVi022601@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e55bae2b2caa67d6b6ee1346fd5cebfe67698677
Commit:        e55bae2b2caa67d6b6ee1346fd5cebfe67698677
Parent:        24751b45bdb1e2f0dc120ccfab7c10b820a1ec53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 2 21:38:32 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: use bash

---
 test/shell/000-basic.sh                            |    3 ++-
 test/shell/aa-lvmlockd-dlm-prepare.sh              |    3 ++-
 test/shell/aa-lvmlockd-sanlock-prepare.sh          |    3 ++-
 test/shell/activate-minor.sh                       |    3 ++-
 test/shell/activate-missing-segment.sh             |    3 ++-
 test/shell/activate-missing.sh                     |    3 ++-
 test/shell/activate-partial.sh                     |    3 ++-
 test/shell/activation-skip.sh                      |    3 ++-
 test/shell/backup-read-only.sh                     |    3 ++-
 test/shell/cache-metadata2.sh                      |    3 ++-
 test/shell/clvmd-restart.sh                        |    3 ++-
 test/shell/covercmd.sh                             |    3 ++-
 test/shell/discards-thin.sh                        |    2 +-
 test/shell/dmeventd-restart.sh                     |    3 ++-
 test/shell/dmsetup-keyring.sh                      |    3 ++-
 test/shell/dmstats-create.sh                       |    3 ++-
 test/shell/dmstats-report.sh                       |    3 ++-
 test/shell/dumpconfig.sh                           |    3 ++-
 test/shell/error-usage.sh                          |    3 ++-
 test/shell/format-lvm1.sh                          |    3 ++-
 test/shell/fsadm-renamed.sh                        |    3 ++-
 test/shell/fsadm.sh                                |    3 ++-
 test/shell/inconsistent-metadata.sh                |    3 ++-
 test/shell/listings.sh                             |    3 ++-
 test/shell/lock-blocking.sh                        |    3 ++-
 test/shell/lock-parallel.sh                        |    3 ++-
 test/shell/losetup-partscan.sh                     |    3 ++-
 test/shell/lv-ancestry.sh                          |    2 +-
 test/shell/lvchange-cache-mode.sh                  |    3 ++-
 test/shell/lvchange-cache-old.sh                   |    3 ++-
 test/shell/lvchange-cache-syncaction-raid.sh       |    3 ++-
 test/shell/lvchange-cache.sh                       |    3 ++-
 test/shell/lvchange-mirror.sh                      |    3 ++-
 test/shell/lvchange-partial-raid10.sh              |    3 ++-
 test/shell/lvchange-partial.sh                     |    3 ++-
 test/shell/lvchange-raid-transient-failures.sh     |    3 ++-
 test/shell/lvchange-raid.sh                        |    3 ++-
 test/shell/lvchange-raid1-writemostly.sh           |    3 ++-
 test/shell/lvchange-raid10.sh                      |    3 ++-
 test/shell/lvchange-raid456.sh                     |    3 ++-
 test/shell/lvchange-rebuild-raid.sh                |    3 ++-
 test/shell/lvchange-syncaction-raid.sh             |    3 ++-
 test/shell/lvchange-thin.sh                        |    3 ++-
 test/shell/lvconvert-cache-abort.sh                |    3 ++-
 test/shell/lvconvert-cache-chunks.sh               |    3 ++-
 test/shell/lvconvert-cache-raid.sh                 |    3 ++-
 test/shell/lvconvert-cache-smq.sh                  |    3 ++-
 test/shell/lvconvert-cache-snapshot.sh             |    2 +-
 test/shell/lvconvert-cache-thin.sh                 |    3 ++-
 test/shell/lvconvert-cache.sh                      |    3 ++-
 test/shell/lvconvert-mirror-basic-0.sh             |    3 ++-
 test/shell/lvconvert-mirror-basic-1.sh             |    3 ++-
 test/shell/lvconvert-mirror-basic-2.sh             |    3 ++-
 test/shell/lvconvert-mirror-basic-3.sh             |    3 ++-
 test/shell/lvconvert-mirror-basic.sh               |    3 ++-
 test/shell/lvconvert-mirror-updown.sh              |    3 ++-
 test/shell/lvconvert-mirror.sh                     |    3 ++-
 test/shell/lvconvert-raid-allocation.sh            |    3 ++-
 test/shell/lvconvert-raid-regionsize.sh            |    3 ++-
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    3 ++-
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    3 ++-
 test/shell/lvconvert-raid-reshape.sh               |    3 ++-
 test/shell/lvconvert-raid-status-validation.sh     |   11 +++++++++++
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |    3 ++-
 test/shell/lvconvert-raid-takeover-thin.sh         |    3 ++-
 test/shell/lvconvert-raid-takeover.sh              |    3 ++-
 test/shell/lvconvert-raid.sh                       |    3 ++-
 test/shell/lvconvert-raid10.sh                     |    3 ++-
 test/shell/lvconvert-raid456.sh                    |    3 ++-
 test/shell/lvconvert-repair-cache.sh               |    2 +-
 test/shell/lvconvert-repair-dmeventd.sh            |    3 ++-
 test/shell/lvconvert-repair-mirror.sh              |    3 ++-
 test/shell/lvconvert-repair-policy.sh              |    3 ++-
 test/shell/lvconvert-repair-raid-dmeventd.sh       |    3 ++-
 test/shell/lvconvert-repair-raid.sh                |    3 ++-
 test/shell/lvconvert-repair-replace.sh             |    3 ++-
 test/shell/lvconvert-repair-snapshot.sh            |    3 ++-
 test/shell/lvconvert-repair-thin-raid.sh           |    2 +-
 test/shell/lvconvert-repair-thin.sh                |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh  |    3 ++-
 test/shell/lvconvert-repair-transient.sh           |    3 ++-
 test/shell/lvconvert-repair.sh                     |    3 ++-
 test/shell/lvconvert-snapshot.sh                   |    2 +-
 test/shell/lvconvert-thin-external-cache.sh        |    2 +-
 test/shell/lvconvert-thin-external.sh              |    2 +-
 test/shell/lvconvert-thin-raid.sh                  |    2 +-
 test/shell/lvconvert-thin.sh                       |    2 +-
 test/shell/lvconvert-twostep.sh                    |    3 ++-
 test/shell/lvcreate-cache-fail.sh                  |    3 ++-
 test/shell/lvcreate-cache-raid.sh                  |    3 ++-
 test/shell/lvcreate-cache-snapshot.sh              |    3 ++-
 test/shell/lvcreate-cache.sh                       |    3 ++-
 test/shell/lvcreate-large-raid.sh                  |    3 ++-
 test/shell/lvcreate-large-raid10.sh                |    3 ++-
 test/shell/lvcreate-large.sh                       |    3 ++-
 test/shell/lvcreate-mirror.sh                      |    3 ++-
 test/shell/lvcreate-missing.sh                     |    3 ++-
 test/shell/lvcreate-operation.sh                   |    3 ++-
 test/shell/lvcreate-pvtags.sh                      |    3 ++-
 test/shell/lvcreate-raid-nosync.sh                 |    3 ++-
 test/shell/lvcreate-raid.sh                        |    3 ++-
 test/shell/lvcreate-raid10.sh                      |    3 ++-
 test/shell/lvcreate-repair.sh                      |    3 ++-
 test/shell/lvcreate-signature-wiping.sh            |    3 ++-
 test/shell/lvcreate-small-snap.sh                  |    3 ++-
 test/shell/lvcreate-striped-mirror.sh              |    3 ++-
 test/shell/lvcreate-thin-big.sh                    |    2 +-
 test/shell/lvcreate-thin-external-size.sh          |    2 +-
 test/shell/lvcreate-thin-external.sh               |    2 +-
 test/shell/lvcreate-thin-power2.sh                 |    2 +-
 test/shell/lvcreate-thin-snap.sh                   |    2 +-
 test/shell/lvcreate-thin.sh                        |    2 +-
 test/shell/lvcreate-usage.sh                       |    3 ++-
 test/shell/lvextend-percent-extents.sh             |    3 ++-
 test/shell/lvextend-snapshot-dmeventd.sh           |    3 ++-
 test/shell/lvextend-snapshot-policy.sh             |    3 ++-
 test/shell/lvextend-thin-data-dmeventd.sh          |    3 ++-
 test/shell/lvextend-thin-full.sh                   |    3 ++-
 test/shell/lvextend-thin-metadata-dmeventd.sh      |    3 ++-
 test/shell/lvextend-thin-raid.sh                   |    3 ++-
 test/shell/lvextend-thin.sh                        |    3 ++-
 test/shell/lvm-init.sh                             |    3 ++-
 test/shell/lvm1-basic.sh                           |    3 ++-
 test/shell/lvmcache-exercise.sh                    |    3 ++-
 test/shell/lvmetad-ambiguous.sh                    |    3 ++-
 test/shell/lvmetad-autoshutdown.sh                 |    3 ++-
 test/shell/lvmetad-client-filter.sh                |    3 ++-
 test/shell/lvmetad-disabled.sh                     |    3 ++-
 test/shell/lvmetad-dump.sh                         |    3 ++-
 test/shell/lvmetad-lvscan-cache.sh                 |    3 ++-
 test/shell/lvmetad-no-cluster.sh                   |    3 ++-
 test/shell/lvmetad-override.sh                     |    3 ++-
 test/shell/lvmetad-pvs.sh                          |    3 ++-
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |    3 ++-
 test/shell/lvmetad-pvscan-cache.sh                 |    3 ++-
 test/shell/lvmetad-pvscan-filter.sh                |    3 ++-
 test/shell/lvmetad-pvscan-md.sh                    |    3 ++-
 test/shell/lvmetad-pvscan-nomda-bg.sh              |    3 ++-
 test/shell/lvmetad-pvscan-nomda.sh                 |    3 ++-
 test/shell/lvmetad-restart.sh                      |    3 ++-
 test/shell/lvmetad-sysinit.sh                      |    3 ++-
 test/shell/lvmetad-test.sh                         |    3 ++-
 test/shell/lvmlockd-hello-world.sh                 |    3 ++-
 test/shell/lvmlockd-lv-types.sh                    |    3 ++-
 test/shell/lvrename-cache-thin.sh                  |    3 ++-
 test/shell/lvresize-full.sh                        |    3 ++-
 test/shell/lvresize-mirror.sh                      |    3 ++-
 test/shell/lvresize-raid.sh                        |    3 ++-
 test/shell/lvresize-raid10.sh                      |    3 ++-
 test/shell/lvresize-rounding.sh                    |    3 ++-
 test/shell/lvresize-thin-external-origin.sh        |    3 ++-
 test/shell/lvresize-thin-metadata.sh               |    3 ++-
 test/shell/lvresize-usage.sh                       |    3 ++-
 test/shell/lvs-cache.sh                            |    3 ++-
 test/shell/mda-rollback.sh                         |    3 ++-
 test/shell/mdata-strings.sh                        |    3 ++-
 test/shell/metadata-balance.sh                     |    3 ++-
 test/shell/metadata-dirs.sh                        |    3 ++-
 test/shell/metadata.sh                             |    3 ++-
 test/shell/mirror-names.sh                         |    5 +++--
 test/shell/mirror-vgreduce-removemissing.sh        |    3 ++-
 test/shell/name-mangling.sh                        |    3 ++-
 test/shell/nomda-missing.sh                        |    2 +-
 test/shell/nomda-restoremissing.sh                 |    3 ++-
 test/shell/orphan-ondisk.sh                        |    3 ++-
 test/shell/pool-labels.sh                          |    3 ++-
 test/shell/process-each-duplicate-pvs.sh           |    3 ++-
 test/shell/process-each-duplicate-vgnames.sh       |    3 ++-
 test/shell/process-each-lv.sh                      |    3 ++-
 test/shell/process-each-pv-nomda-all.sh            |    3 ++-
 test/shell/process-each-pv-nomda.sh                |    3 ++-
 test/shell/process-each-pv.sh                      |    3 ++-
 test/shell/process-each-pvresize.sh                |    3 ++-
 test/shell/process-each-vg.sh                      |    3 ++-
 test/shell/process-each-vgreduce.sh                |    3 ++-
 test/shell/profiles-cache.sh                       |    3 ++-
 test/shell/profiles-thin.sh                        |    2 +-
 test/shell/profiles.sh                             |    2 +-
 test/shell/pv-check-dev-size.sh                    |    3 ++-
 test/shell/pv-duplicate-uuid.sh                    |    3 ++-
 test/shell/pv-duplicate.sh                         |    3 ++-
 test/shell/pv-ext-flags.sh                         |    3 ++-
 test/shell/pv-ext-update.sh                        |    3 ++-
 test/shell/pv-min-size.sh                          |    3 ++-
 test/shell/pv-range-overflow.sh                    |    3 ++-
 test/shell/pvchange-usage.sh                       |    3 ++-
 test/shell/pvcreate-bootloaderarea.sh              |    3 ++-
 test/shell/pvcreate-ff.sh                          |    3 ++-
 test/shell/pvcreate-metadata0.sh                   |    3 ++-
 test/shell/pvcreate-operation-md.sh                |    3 ++-
 test/shell/pvcreate-operation.sh                   |    2 ++
 test/shell/pvcreate-restore.sh                     |    3 ++-
 test/shell/pvcreate-usage.sh                       |    3 ++-
 test/shell/pvmove-abort-all.sh                     |    3 ++-
 test/shell/pvmove-abort.sh                         |    3 ++-
 test/shell/pvmove-all-segtypes.sh                  |    3 ++-
 test/shell/pvmove-background.sh                    |    3 ++-
 test/shell/pvmove-basic.sh                         |    3 ++-
 test/shell/pvmove-cache-segtypes.sh                |    3 ++-
 test/shell/pvmove-raid-segtypes.sh                 |    3 ++-
 test/shell/pvmove-restart.sh                       |    3 ++-
 test/shell/pvmove-resume-1.sh                      |    3 ++-
 test/shell/pvmove-resume-2.sh                      |    3 ++-
 test/shell/pvmove-resume-multiseg.sh               |    3 ++-
 test/shell/pvmove-thin-segtypes.sh                 |    3 ++-
 test/shell/pvremove-thin.sh                        |    3 ++-
 test/shell/pvremove-usage.sh                       |    3 ++-
 test/shell/pvremove-warnings.sh                    |    2 ++
 test/shell/pvresize-mdas.sh                        |    3 ++-
 test/shell/read-ahead.sh                           |    3 ++-
 test/shell/relative-sign-options.sh                |    3 ++-
 test/shell/report-fields.sh                        |    3 ++-
 test/shell/report-hidden.sh                        |    3 ++-
 test/shell/select-report.sh                        |    3 ++-
 test/shell/select-tools-thin.sh                    |    3 ++-
 test/shell/select-tools.sh                         |    3 ++-
 test/shell/snapshot-autoumount-dmeventd.sh         |    3 ++-
 test/shell/snapshot-cluster.sh                     |    3 ++-
 test/shell/snapshot-lvm1.sh                        |    3 ++-
 test/shell/snapshot-maxsize.sh                     |    3 ++-
 test/shell/snapshot-merge-stack.sh                 |    3 ++-
 test/shell/snapshot-merge.sh                       |    3 ++-
 test/shell/snapshot-reactivate.sh                  |    3 ++-
 test/shell/snapshot-remove-dmsetup.sh              |    3 ++-
 test/shell/snapshot-rename.sh                      |    3 ++-
 test/shell/snapshot-usage-exa.sh                   |    3 ++-
 test/shell/snapshot-usage.sh                       |    3 ++-
 test/shell/snapshots-of-mirrors.sh                 |    3 ++-
 test/shell/stray-device-node.sh                    |    3 ++-
 test/shell/system_id.sh                            |    3 ++-
 test/shell/tags.sh                                 |    3 ++-
 test/shell/test-partition.sh                       |    3 ++-
 test/shell/thin-autoumount-dmeventd.sh             |    3 ++-
 test/shell/thin-defaults.sh                        |    3 ++-
 test/shell/thin-dmeventd-warns.sh                  |    2 +-
 test/shell/thin-flags.sh                           |    3 ++-
 test/shell/thin-foreign-dmeventd.sh                |    2 +-
 test/shell/thin-large.sh                           |    3 ++-
 test/shell/thin-merge.sh                           |    3 ++-
 test/shell/thin-overprovisioning.sh                |    3 ++-
 test/shell/thin-resize-match.sh                    |    3 ++-
 test/shell/thin-restore.sh                         |    3 ++-
 test/shell/thin-vglock.sh                          |    3 ++-
 test/shell/thin-volume-list.sh                     |    3 ++-
 test/shell/topology-support.sh                     |    3 ++-
 test/shell/unknown-segment.sh                      |    3 ++-
 test/shell/unlost-pv.sh                            |    3 ++-
 test/shell/vg-check-devs-used.sh                   |    3 ++-
 test/shell/vg-name-from-env.sh                     |    3 ++-
 test/shell/vgcfgbackup-lvm1.sh                     |    3 ++-
 test/shell/vgcfgbackup-usage.sh                    |    3 ++-
 test/shell/vgchange-many.sh                        |    3 ++-
 test/shell/vgchange-maxlv.sh                       |    3 ++-
 test/shell/vgchange-partial.sh                     |    3 ++-
 test/shell/vgchange-sysinit.sh                     |    3 ++-
 test/shell/vgchange-usage.sh                       |    3 ++-
 test/shell/vgck.sh                                 |    3 ++-
 test/shell/vgcreate-many-pvs.sh                    |    3 ++-
 test/shell/vgcreate-usage.sh                       |    3 ++-
 test/shell/vgextend-restoremissing.sh              |    3 ++-
 test/shell/vgextend-usage.sh                       |    3 ++-
 test/shell/vgimportclone.sh                        |    3 ++-
 test/shell/vgmerge-operation.sh                    |    3 ++-
 test/shell/vgmerge-usage.sh                        |    3 ++-
 test/shell/vgreduce-removemissing-snapshot.sh      |    3 ++-
 test/shell/vgreduce-usage.sh                       |    3 ++-
 test/shell/vgremove-corrupt-vg.sh                  |    3 ++-
 test/shell/vgrename-usage.sh                       |    3 ++-
 test/shell/vgsplit-operation.sh                    |    3 ++-
 test/shell/vgsplit-raid.sh                         |    3 ++-
 test/shell/vgsplit-stacked.sh                      |    3 ++-
 test/shell/vgsplit-thin.sh                         |    3 ++-
 test/shell/vgsplit-usage.sh                        |    3 ++-
 test/shell/zz-lvmlockd-dlm-remove.sh               |    3 ++-
 test/shell/zz-lvmlockd-sanlock-remove.sh           |    3 ++-
 275 files changed, 538 insertions(+), 273 deletions(-)

diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index da84f3e..2222456 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/aa-lvmlockd-dlm-prepare.sh b/test/shell/aa-lvmlockd-dlm-prepare.sh
index bc30bb7..7e3700f 100644
--- a/test/shell/aa-lvmlockd-dlm-prepare.sh
+++ b/test/shell/aa-lvmlockd-dlm-prepare.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 75b94e7..b897bbd 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index bb78c7f..187a4aa 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index 7f26e11..777a1bf 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 3e34471..6b62115 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index e686ec6..be21d7c 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index 8935286..7aca44c 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/backup-read-only.sh b/test/shell/backup-read-only.sh
index 178c49b..f7033cb 100644
--- a/test/shell/backup-read-only.sh
+++ b/test/shell/backup-read-only.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/cache-metadata2.sh b/test/shell/cache-metadata2.sh
index acf6d0d..a7586f7 100644
--- a/test/shell/cache-metadata2.sh
+++ b/test/shell/cache-metadata2.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index e6067f5..e3c9d5f 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 00b1781..dbf8205 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 9a66dc8..2efb060 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index a5caf98..87e3e40 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
index b308975..0f730a9 100644
--- a/test/shell/dmsetup-keyring.sh
+++ b/test/shell/dmsetup-keyring.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index a52cd34..c16f26f 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
index 56f913d..0312149 100644
--- a/test/shell/dmstats-report.sh
+++ b/test/shell/dmstats-report.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index d62d28c..062def9 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 062b71e..d75eacf 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/format-lvm1.sh b/test/shell/format-lvm1.sh
index a310b12..b88579f 100644
--- a/test/shell/format-lvm1.sh
+++ b/test/shell/format-lvm1.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index 9f3cd3c..ed7b743 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 6eff24a..351a179 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 808616b..cbb8412 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 0eac8f6..8de9490 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index c144a8e..85f7a10 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index 6a565a9..89fb397 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/losetup-partscan.sh b/test/shell/losetup-partscan.sh
index 1a3c70a..df32b61 100644
--- a/test/shell/losetup-partscan.sh
+++ b/test/shell/losetup-partscan.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lv-ancestry.sh b/test/shell/lv-ancestry.sh
index 0e0cc79..e32dfa3 100644
--- a/test/shell/lv-ancestry.sh
+++ b/test/shell/lv-ancestry.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
index f7b1081..2bb8641 100644
--- a/test/shell/lvchange-cache-mode.sh
+++ b/test/shell/lvchange-cache-mode.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-cache-old.sh b/test/shell/lvchange-cache-old.sh
index 018d384..cb7915d 100644
--- a/test/shell/lvchange-cache-old.sh
+++ b/test/shell/lvchange-cache-old.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-cache-syncaction-raid.sh b/test/shell/lvchange-cache-syncaction-raid.sh
index 6a4546e..206c750 100644
--- a/test/shell/lvchange-cache-syncaction-raid.sh
+++ b/test/shell/lvchange-cache-syncaction-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 385fcf4..73ad6c0 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 8875f05..8120dbe 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index 125129b..83193b2 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 63ede22..60b2b50 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-raid-transient-failures.sh b/test/shell/lvchange-raid-transient-failures.sh
index 3082cd6..a478204 100644
--- a/test/shell/lvchange-raid-transient-failures.sh
+++ b/test/shell/lvchange-raid-transient-failures.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 1677d4f..2fe011a 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index 2466de3..32e84db 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-raid10.sh b/test/shell/lvchange-raid10.sh
index 4c0a1c2..a29ade9 100644
--- a/test/shell/lvchange-raid10.sh
+++ b/test/shell/lvchange-raid10.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
index 5cdcbde..ea4b4e2 100644
--- a/test/shell/lvchange-raid456.sh
+++ b/test/shell/lvchange-raid456.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 4460a5c..d7fa7e7 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 7d7d3ed..84961ed 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index e45f7c8..99215d9 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 65a6787..18b509e 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
index a525a95..4046722 100644
--- a/test/shell/lvconvert-cache-chunks.sh
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index e2fbf94..9e4f55c 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-cache-smq.sh b/test/shell/lvconvert-cache-smq.sh
index 19daebf..e329aee 100644
--- a/test/shell/lvconvert-cache-smq.sh
+++ b/test/shell/lvconvert-cache-smq.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-cache-snapshot.sh b/test/shell/lvconvert-cache-snapshot.sh
index 8f0ab53..ac9d3dd 100644
--- a/test/shell/lvconvert-cache-snapshot.sh
+++ b/test/shell/lvconvert-cache-snapshot.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index 864ea7e..e1d38b8 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index b1ac154..df72f4f 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror-basic-0.sh b/test/shell/lvconvert-mirror-basic-0.sh
index 8476f6e..02f32a9 100644
--- a/test/shell/lvconvert-mirror-basic-0.sh
+++ b/test/shell/lvconvert-mirror-basic-0.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror-basic-1.sh b/test/shell/lvconvert-mirror-basic-1.sh
index e707b1c..76d1315 100644
--- a/test/shell/lvconvert-mirror-basic-1.sh
+++ b/test/shell/lvconvert-mirror-basic-1.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror-basic-2.sh b/test/shell/lvconvert-mirror-basic-2.sh
index 3e717f3..eb6de87 100644
--- a/test/shell/lvconvert-mirror-basic-2.sh
+++ b/test/shell/lvconvert-mirror-basic-2.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror-basic-3.sh b/test/shell/lvconvert-mirror-basic-3.sh
index 6a4f289..fa4b3cd 100644
--- a/test/shell/lvconvert-mirror-basic-3.sh
+++ b/test/shell/lvconvert-mirror-basic-3.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index c32b5c1..0b73d8c 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index 13c77ce..b419f2e 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 810d13e..4fc80ac 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index 1a768b6..0d8c794 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index d2c8a54..4763bab 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 0b589b4..0be8777 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index d34ca5e..ba90f57 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index e4ade3f..73d1365 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index e860f9d..fb5912f 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -1,4 +1,15 @@
 #!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
+
 #######################################################################
 # This series of tests is meant to validate the correctness of
 # 'dmsetup status' for RAID LVs - especially during various sync action
diff --git a/test/shell/lvconvert-raid-takeover-alloc-failure.sh b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
index cf926a1..969ce27 100644
--- a/test/shell/lvconvert-raid-takeover-alloc-failure.sh
+++ b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-takeover-thin.sh b/test/shell/lvconvert-raid-takeover-thin.sh
index 647b133..580c1be 100644
--- a/test/shell/lvconvert-raid-takeover-thin.sh
+++ b/test/shell/lvconvert-raid-takeover-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 8e3ffb1..c9b45e9 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016,2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index e748003..a110ac5 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index e41b5bf..ec27fca 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 8c87a03..0e3f378 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index f709813..c68fdbd 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 2856227..b7efda2 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-mirror.sh b/test/shell/lvconvert-repair-mirror.sh
index a4d3a73..dcd8d07 100644
--- a/test/shell/lvconvert-repair-mirror.sh
+++ b/test/shell/lvconvert-repair-mirror.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 2ef5f1b..15d4e7c 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index 5b5bdcc..f08b3da 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index db38e98..93b7db2 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 9444417..4a55969 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 269559d..8e66664 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-thin-raid.sh b/test/shell/lvconvert-repair-thin-raid.sh
index 7afceef..3d89647 100644
--- a/test/shell/lvconvert-repair-thin-raid.sh
+++ b/test/shell/lvconvert-repair-thin-raid.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 8930894..9b94cbf 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 59c7648..7b2dd3f 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 947ae45..082f7f2 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 43a7ee9..e0916e7 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 6e73563..d63cc67 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-thin-external-cache.sh b/test/shell/lvconvert-thin-external-cache.sh
index c4d7d61..465ce52 100644
--- a/test/shell/lvconvert-thin-external-cache.sh
+++ b/test/shell/lvconvert-thin-external-cache.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 470e87c..333a718 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index b243a55..8efafbc 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2014-2017 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 992a1f2..6960cd8 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index 9c54756..cbdf862 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-cache-fail.sh b/test/shell/lvcreate-cache-fail.sh
index 2ff4865..dc7c53a 100644
--- a/test/shell/lvcreate-cache-fail.sh
+++ b/test/shell/lvcreate-cache-fail.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-cache-raid.sh b/test/shell/lvcreate-cache-raid.sh
index df7be6b..d540d4e 100644
--- a/test/shell/lvcreate-cache-raid.sh
+++ b/test/shell/lvcreate-cache-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-cache-snapshot.sh b/test/shell/lvcreate-cache-snapshot.sh
index 6b6ef2c..c1be6a2 100644
--- a/test/shell/lvcreate-cache-snapshot.sh
+++ b/test/shell/lvcreate-cache-snapshot.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index f19965a..8edbeb2 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 27015b7..5562ead 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012,2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 33af630..a46be37 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012,2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 6fc4c5e..473b0ed 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index 0e9bd21..e9ffd3e 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index c8add08..fda62c6 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 9062d5d..7094a61 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 59c2d75..ef6c422 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 9bbc226..c0e23bb 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 61032c9..eedc3d1 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index be2bd45..4bb785d 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index f3be28a..456788d 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 6699832..d70d85a 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index d7b5104..be44dce 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index 35d8b05..eb40bfa 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 235eead..c6c4a19 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index 9a28591..d26f590 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 8a10c18..a24136e 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index 797bced..3c39d59 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index da02641..2b4ddc4 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 3fb1e73..1b7c238 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2011-2014 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index f7b4704..edae918 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 83e5994..2a807fa 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 6165128..0f9b0a9 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index 236c3f6..47def93 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-thin-data-dmeventd.sh b/test/shell/lvextend-thin-data-dmeventd.sh
index ceb9088..b5b21eb 100644
--- a/test/shell/lvextend-thin-data-dmeventd.sh
+++ b/test/shell/lvextend-thin-data-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index 3bafad4..e23eca8 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 6d27600..eacacb3 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-thin-raid.sh b/test/shell/lvextend-thin-raid.sh
index 1688ffb..a623bb8 100644
--- a/test/shell/lvextend-thin-raid.sh
+++ b/test/shell/lvextend-thin-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index c5bb2cf..82d8983 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvm-init.sh b/test/shell/lvm-init.sh
index a5435fe..92e050b 100644
--- a/test/shell/lvm-init.sh
+++ b/test/shell/lvm-init.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvm1-basic.sh b/test/shell/lvm1-basic.sh
index 166d5bf..93509c4 100644
--- a/test/shell/lvm1-basic.sh
+++ b/test/shell/lvm1-basic.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index af85b90..ee1a9e3 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 52f2928..71677c8 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-autoshutdown.sh b/test/shell/lvmetad-autoshutdown.sh
index 4491e08..c8a5c0c 100644
--- a/test/shell/lvmetad-autoshutdown.sh
+++ b/test/shell/lvmetad-autoshutdown.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-client-filter.sh b/test/shell/lvmetad-client-filter.sh
index 51d25ff..095099b 100644
--- a/test/shell/lvmetad-client-filter.sh
+++ b/test/shell/lvmetad-client-filter.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 28ccdac..cba73d6 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 49cf9b7..ecda3ed 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
index 3b6528e..28b62fd 100644
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index d894114..d5eb23b 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index c71a0c6..91367ff 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 2f51944..ba52d8a 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
index 3f8e011..46c454b 100644
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index c0b7f43..e57030d 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index cb3fcdc..677b35f 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index f5b91d7..4d4dae2 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvscan-nomda-bg.sh b/test/shell/lvmetad-pvscan-nomda-bg.sh
index 443f8b6..351e446 100644
--- a/test/shell/lvmetad-pvscan-nomda-bg.sh
+++ b/test/shell/lvmetad-pvscan-nomda-bg.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index fe04b00..c28d984 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index e2f2666..2e49f75 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-sysinit.sh b/test/shell/lvmetad-sysinit.sh
index 33f80fe..8116e51 100644
--- a/test/shell/lvmetad-sysinit.sh
+++ b/test/shell/lvmetad-sysinit.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
index 2fe06ba..0daf1e4 100644
--- a/test/shell/lvmetad-test.sh
+++ b/test/shell/lvmetad-test.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmlockd-hello-world.sh b/test/shell/lvmlockd-hello-world.sh
index 01e1c56..e0a1505 100644
--- a/test/shell/lvmlockd-hello-world.sh
+++ b/test/shell/lvmlockd-hello-world.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index 8e12776..b82f21b 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvrename-cache-thin.sh b/test/shell/lvrename-cache-thin.sh
index 33d0e34..eb1b726 100644
--- a/test/shell/lvrename-cache-thin.sh
+++ b/test/shell/lvrename-cache-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
index 3eef11a..b518bb7 100644
--- a/test/shell/lvresize-full.sh
+++ b/test/shell/lvresize-full.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index cc86a35..8489b63 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 691946d..51a20c4 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012,2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index dc6e2fb..5f400ac 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 1f18ee5..754127b 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index 686da39..aa5e4bf 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index a08fb40..54142ce 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 30cb8d5..23f73ae 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2007-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index f2463b8..84ac026 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index 0fd095a..dbfdc7d 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 5d22953..4fcb89c 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 29e9135..3855b88 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index 525f77f..3c21ac8 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 8ed5414..aac4f12 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 1b9cece..f3bfe41 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -1,5 +1,6 @@
-#!/bin/sh
-# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
+#!/usr/bin/env bash
+
+# Copyright (C) 2007-2017 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007-2008 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index eb51af6..ac7303f 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 049064e..80e7b6c 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index 9fe4bec..bb92fe7 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index 811637b..a14f58d 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index 0d46cd6..4c8dabd 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index 86f5fec..e7de6fc 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index fcd8da1..98dd285 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 532c669..ea79c91 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 0fd08ba..14cb110 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
index 7d9cc14..020f831 100644
--- a/test/shell/process-each-pv-nomda-all.sh
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index d48da26..8f09129 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-pv.sh b/test/shell/process-each-pv.sh
index 68429b2..beb7a6c 100644
--- a/test/shell/process-each-pv.sh
+++ b/test/shell/process-each-pv.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index e1e4af3..26b65d4 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-vg.sh b/test/shell/process-each-vg.sh
index 6d7b716..569cf08 100644
--- a/test/shell/process-each-vg.sh
+++ b/test/shell/process-each-vg.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/process-each-vgreduce.sh b/test/shell/process-each-vgreduce.sh
index e9f024a..3cec6c8 100644
--- a/test/shell/process-each-vgreduce.sh
+++ b/test/shell/process-each-vgreduce.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index f2acadb..1765150 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index d97bf59..a3a8b05 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 508f6db..923baec 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/pv-check-dev-size.sh b/test/shell/pv-check-dev-size.sh
index a3013c4..58207c3 100644
--- a/test/shell/pv-check-dev-size.sh
+++ b/test/shell/pv-check-dev-size.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index c846a50..d1664a4 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index 9e78ae8..133f032 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index 3e0f3c3..cc21eab 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pv-ext-update.sh b/test/shell/pv-ext-update.sh
index eb4e7a9..cfaece7 100644
--- a/test/shell/pv-ext-update.sh
+++ b/test/shell/pv-ext-update.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pv-min-size.sh b/test/shell/pv-min-size.sh
index 611fb3f..3d3d5e9 100644
--- a/test/shell/pv-min-size.sh
+++ b/test/shell/pv-min-size.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index 2d80f4e..08401db 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 0a0a9c1..383986e 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index e0f6d2f..258c4cb 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
index a259de7..13b05fc 100644
--- a/test/shell/pvcreate-ff.sh
+++ b/test/shell/pvcreate-ff.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index cfa98e1..ce29a5f 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 0e7835f..447b15e 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2009-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index c5c9f80..ad80375 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -1,3 +1,5 @@
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
index 7a4a57c..d0b46eb 100644
--- a/test/shell/pvcreate-restore.sh
+++ b/test/shell/pvcreate-restore.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 0a913d4..97342ba 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 77f8108..7cb549f 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 1438ab6..218864c 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 6a34ecf..e10586e 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index 26970d4..6a158e4 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 581597b..1cc5595 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index bd624bc..f95ba72 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 0025ba2..c11210d 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index e7ed78b..14806cb 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index b13e00d..1f797d4 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 47f4f22..73c42c8 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 7783c83..2737939 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index e8fa26b..9a480c1 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 5ae0e0a..9bb9d44 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index e0f51bf..be51ce1 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index 4fb5eba..57a376c 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -1,3 +1,5 @@
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/pvresize-mdas.sh b/test/shell/pvresize-mdas.sh
index c2571f1..3bed8bc 100644
--- a/test/shell/pvresize-mdas.sh
+++ b/test/shell/pvresize-mdas.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index a16cb40..f21c52c 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 3bf076a..2db281a 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/report-fields.sh b/test/shell/report-fields.sh
index 5901198..0473a33 100644
--- a/test/shell/report-fields.sh
+++ b/test/shell/report-fields.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
index 2607444..fb70e60 100644
--- a/test/shell/report-hidden.sh
+++ b/test/shell/report-hidden.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index aad3857..314e207 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index b870191..aa43ef3 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index 3485f85..2b28599 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 8019281..5ef3969 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-cluster.sh b/test/shell/snapshot-cluster.sh
index a4d5fb9..d6459d8 100644
--- a/test/shell/snapshot-cluster.sh
+++ b/test/shell/snapshot-cluster.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index bc12113..3a078b5 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index e8e08b5..51d9d6d 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index 0f733bd..6eca2a0 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 07756d5..9b2d663 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index 5adf1f8..fb6973a 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 05bf720..a7925d5 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-rename.sh b/test/shell/snapshot-rename.sh
index 978debe..a7eb54c 100644
--- a/test/shell/snapshot-rename.sh
+++ b/test/shell/snapshot-rename.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index edc1e50..6c4cb7e 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index a751f1a..3661022 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index 49cd476..a23cc58 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index d4d9740..162913b 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 5d13547..9e53a26 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index 3abf856..2d8731e 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index 9e9366b..bcbf9f1 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index b0bbda3..cee2f4c 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2012-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 7e26bb7..89c0fa4 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
index cbab5df..29d3c4f 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 7d87553..12b1b75 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index f78fcf8..4e373ad 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/shell/thin-large.sh b/test/shell/thin-large.sh
index da5a7ec..b1cf29a 100644
--- a/test/shell/thin-large.sh
+++ b/test/shell/thin-large.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 9955aab..7baaa55 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-overprovisioning.sh b/test/shell/thin-overprovisioning.sh
index 07c74cc..85d8577 100644
--- a/test/shell/thin-overprovisioning.sh
+++ b/test/shell/thin-overprovisioning.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index 46b4531..b9bec9c 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index 270bae6..afcbd7f 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index 40f3adf..9664e30 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index 315353c..f4fb0a3 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 90e3d0d..1cb0f49 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index 20fc920..cadbe19 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2009 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index f23b018..982e340 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index 37f8f43..7d44812 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index be94406..9ba6b45 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgcfgbackup-lvm1.sh b/test/shell/vgcfgbackup-lvm1.sh
index f3c7ab4..644f9b3 100644
--- a/test/shell/vgcfgbackup-lvm1.sh
+++ b/test/shell/vgcfgbackup-lvm1.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index f923049..6183490 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index f4fca78..72dcc0c 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 1509444..455dbfe 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index 4311b59..b77ad1a 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -1,4 +1,5 @@
-#!/bin/bash
+#!/usr/bin/env bash
+
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index 4941ed6..ec0a6cd 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 44e0fd9..1520142 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 6092f12..2f3fba4 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
index 1052200..a75b3f3 100644
--- a/test/shell/vgcreate-many-pvs.sh
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index 4161268..16117c3 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index d94eb5c..196d82f 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index a470f71..a3bfa2a 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index d7b7c96..f97c6df 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 605d2c4..21889e9 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgmerge-usage.sh b/test/shell/vgmerge-usage.sh
index 7369ad9..fa9bb19 100644
--- a/test/shell/vgmerge-usage.sh
+++ b/test/shell/vgmerge-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index 4ab60a7..8ddb3d9 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 37a27a0..d721514 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index 4d325d9..edc911b 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index c052f97..3b69453 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index d3c81d9..5dff173 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index 8db307c..dc2ef5a 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index b09e336..1388e91 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 6fc825d..4a71426 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index 0ca89d9..f49e13a 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2007-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/zz-lvmlockd-dlm-remove.sh b/test/shell/zz-lvmlockd-dlm-remove.sh
index 0526314..c7dfb1d 100644
--- a/test/shell/zz-lvmlockd-dlm-remove.sh
+++ b/test/shell/zz-lvmlockd-dlm-remove.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/shell/zz-lvmlockd-sanlock-remove.sh b/test/shell/zz-lvmlockd-sanlock-remove.sh
index b01952a..081ee69 100644
--- a/test/shell/zz-lvmlockd-sanlock-remove.sh
+++ b/test/shell/zz-lvmlockd-sanlock-remove.sh
@@ -1,4 +1,5 @@
-#!/bin/sh
+#!/usr/bin/env bash
+
 # Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,


