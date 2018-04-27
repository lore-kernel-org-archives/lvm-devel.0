From: David Teigland <teigland@sourceware.org>
Date: Fri, 27 Apr 2018 17:26:08 -0400
Subject: master - test: remove pv-duplicate
Message-ID: <201804272126.w3RLQ8VV027880@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=138225a3a8c03a5a2db5e0af0b1c78d32be07b88
Commit:        138225a3a8c03a5a2db5e0af0b1c78d32be07b88
Parent:        ab63923d19afe3f72d4806082fb8496c8c7900f9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 27 11:42:58 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 27 16:25:41 2018 -0500

test: remove pv-duplicate

This wasn't testing duplicate PVs, which are tested by
process-each-duplicate-pvs.sh.
---
 test/shell/pv-duplicate.sh |   41 -----------------------------------------
 1 files changed, 0 insertions(+), 41 deletions(-)

diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
deleted file mode 100644
index 133f032..0000000
--- a/test/shell/pv-duplicate.sh
+++ /dev/null
@@ -1,41 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# 'Exercise duplicate metadata diagnostics'
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 3
-
-pvcreate "$dev1"
-
-dd if="$dev1" of=backup_dev1 bs=256K count=1
-
-vgcreate --metadatasize 128k $vg1 "$dev1"
-
-# copy mda
-dd if="$dev1" of="$dev2" bs=256K count=1
-dd if="$dev1" of="$dev3" bs=256K count=1
-
-pvs "$dev3" -o pv_uuid
-
-vgs $vg1
-
-dd if=backup_dev1 of="$dev3" bs=256K count=1
-pvs
-#-vvvv
-# TODO: Surely needs more inspecition about correct
-#       behavior for such case
-# vgs $vg1


