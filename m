From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 15:33:31 -0400
Subject: master - tests: remove metadata-dirs
Message-ID: <201806131933.w5DJXVMc017199@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d067263f51f782661d6faa00b106b872b3e1dc6f
Commit:        d067263f51f782661d6faa00b106b872b3e1dc6f
Parent:        5fca75877d8af5fe6f277159490eda4817740060
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 14:14:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 14:14:23 2018 -0500

tests: remove metadata-dirs

metadata dirs are removed
---
 test/shell/metadata-dirs.sh |   48 -------------------------------------------
 1 files changed, 0 insertions(+), 48 deletions(-)

diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
deleted file mode 100644
index 2a43340..0000000
--- a/test/shell/metadata-dirs.sh
+++ /dev/null
@@ -1,48 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 3
-get_devs
-
-pvcreate --metadatacopies 0 "${DEVICES[@]}"
-not vgcreate $SHARED "$vg" "${DEVICES[@]}"
-
-aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\" ]"
-
-vgcreate $SHARED $vg "$dev1"
-check vg_field $vg vg_mda_count 1
-vgremove -ff $vg
-
-vgcreate $SHARED "$vg" "${DEVICES[@]}"
-check vg_field $vg vg_mda_count 1
-vgremove -ff $vg
-
-pvcreate --metadatacopies 1 --metadataignore y "$dev1"
-vgcreate $SHARED "$vg" "${DEVICES[@]}"
-check vg_field $vg vg_mda_count 2
-vgremove -ff $vg
-
-pvcreate --metadatacopies 1 --metadataignore n "$dev1"
-vgcreate $SHARED "$vg" "${DEVICES[@]}"
-check vg_field $vg vg_mda_count 2
-vgremove -ff $vg
-
-pvcreate --metadatacopies 0 "$dev1"
-aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\", \"$TESTDIR/mda2\" ]"
-vgcreate $SHARED "$vg" "${DEVICES[@]}"
-check vg_field $vg vg_mda_count 2
-vgremove -ff $vg


