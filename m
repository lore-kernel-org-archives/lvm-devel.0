From: David Teigland <teigland@sourceware.org>
Date: Wed, 24 Feb 2021 16:22:13 +0000 (GMT)
Subject: main - tests: real_devs remove mistakenly added test
Message-ID: <20210224162213.BE91E38708D9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6fad7f2eac84af60d301816dc06ef7276cd6415f
Commit:        6fad7f2eac84af60d301816dc06ef7276cd6415f
Parent:        91d6822534026dc9110d478d214d27d0b3a3e61b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 24 10:19:00 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 24 10:21:18 2021 -0600

tests: real_devs remove mistakenly added test

devicesfile-realdevs is the correct one
---
 test/shell/real_devs.sh | 39 ---------------------------------------
 1 file changed, 39 deletions(-)

diff --git a/test/shell/real_devs.sh b/test/shell/real_devs.sh
deleted file mode 100644
index a1a49c8bb..000000000
--- a/test/shell/real_devs.sh
+++ /dev/null
@@ -1,39 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-test_description='hello world for user-defined device list'
-
-. lib/inittest
-
-aux prepare_real_devs
-
-echo "$dev1"
-
-pvcreate "$dev1"
-
-pvs "$dev1"
-
-pvremove "$dev1"
-
-vgcreate $vg "$dev1"
-
-lvcreate -l1 $vg
-
-vgchange -an $vg
-
-vgremove -ff $vg
-
-get_real_devs
-for d in "${REAL_DEVICES[@]}"; do
-	echo $d
-done
-


