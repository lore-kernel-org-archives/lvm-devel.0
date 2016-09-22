From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Sep 2016 13:48:23 +0000 (UTC)
Subject: master - tests: check for TRIM support
Message-ID: <20160922134823.5C1B06024E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb6b2a11e3548f7598c726787494be2c3ea4dca1
Commit:        eb6b2a11e3548f7598c726787494be2c3ea4dca1
Parent:        f1cad4c7103ac0edc0b724217b50d062326deb43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 22 15:37:52 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 22 15:37:52 2016 +0200

tests: check for TRIM support

passdown can really work only on discardable device.
Skip 'status' test when PV does no support discard.
---
 test/shell/lvchange-thin.sh |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index f943401..b5a6a86 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2013-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -25,24 +25,31 @@ vgcreate -s 128k $vg2 "$dev3"
 
 lvcreate -L10M -T $vg/pool
 
+# When PV does not support discard
+# tests for checking thin-pool discard passdown are skipped
+pvmajor=$(get pv_field "$dev1" major)
+pvminor=$(get pv_field "$dev1" minor)
+test "$(< /sys/dev/block/$pvmajor\:$pvminor/queue/discard_granularity)" -ne "0" || \
+        no_discard=1
+
 #
 # Check change operations on a thin-pool without any thin LV
 #
 # discards_ARG  (default is passdown)
-check grep_dmsetup status $vg-pool " discard_passdown" || {
+test -n "$no_discard" || check grep_dmsetup status $vg-pool " discard_passdown" || {
 	# trace device layout
 	grep -r "" /sys/block/*
 	die "Device was expected to support passdown"
 }
 
-lvchange -vvvv --discards nopassdown $vg/pool
+lvchange --discards nopassdown $vg/pool
 check grep_dmsetup table $vg-pool " no_discard_passdown"
-check grep_dmsetup status $vg-pool " no_discard_passdown"
+test -n "$no_discard" || check grep_dmsetup status $vg-pool " no_discard_passdown"
 
 lvchange --discards passdown $vg/pool
 check grep_dmsetup table $vg-pool -v "passdown"
-check grep_dmsetup status $vg-pool " discard_passdown"
-
+test -n "$no_discard" || check grep_dmsetup status $vg-pool " discard_passdown"
+exit
 # zero_ARG  (default is 'yes')
 check grep_dmsetup table $vg-pool -v "zeroing"
 lvchange --zero n $vg/pool
@@ -112,10 +119,10 @@ lvchange --deltag foo $vg/pool
 # discards_ARG
 lvchange --discards nopassdown $vg/pool
 check grep_dmsetup table $vg-pool-tpool " no_discard_passdown"
-check grep_dmsetup status $vg-pool-tpool " no_discard_passdown"
+test -n "$no_discard" || check grep_dmsetup status $vg-pool-tpool " no_discard_passdown"
 lvchange --discards passdown $vg/pool
 check grep_dmsetup table $vg-pool-tpool -v "passdown"
-check grep_dmsetup status $vg-pool-tpool " discard_passdown"
+test -n "$no_discard" || check grep_dmsetup status $vg-pool-tpool " discard_passdown"
 
 # zero_ARG
 lvchange --zero n $vg/pool


