From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Jan 2020 09:22:47 -0500
Subject: stable-2.02 - tests: add corruption write on PV test
Message-ID: <17087.120012009224300337@us-mta-146.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c66e01569862a421d137eedbf9e6abe4e1152853
Commit:        c66e01569862a421d137eedbf9e6abe4e1152853
Parent:        9b41118b9c8fed755eaabb1b0833f2518ddf1c36
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 20 14:16:13 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 20 15:21:38 2020 +0100

tests: add corruption write on PV test

Test a case where PV is readable, but fails on write updating.
Check the failure is reported only for a single PV.
---
 test/shell/pv-corruption.sh | 52 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/test/shell/pv-corruption.sh b/test/shell/pv-corruption.sh
new file mode 100644
index 0000000..3958ee1
--- /dev/null
+++ b/test/shell/pv-corruption.sh
@@ -0,0 +1,52 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# tests, write failer on PV1 is not reporting errors on PV2 or PV3...
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+#
+# Main
+#
+aux prepare_devs 3 20
+
+pvcreate -y --setphysicalvolumesize 10m "$dev1"
+pvcreate "$dev2"
+pvcreate "$dev3"
+
+vgcreate $vg "$dev1" "$dev2" "$dev3"
+
+pvs -o +uuid
+
+# Keep device readable, but any write fails
+aux writeerror_dev "$dev1" 0:100
+
+# Suppose to fail, size PV1 is not writable
+not pvresize "$dev1" 2>&1 | tee out
+
+# Output should not complain about any error on pv2 nor pv3
+not grep pv2 out
+not grep pv3 out
+
+# Restore working PV1 back
+aux enable_dev "$dev1"
+
+# FIXME: Takes a lot of time ATM....
+pvck "$dev2"
+
+pvs -o +uuid
+vgdisplay
+
+vgremove $vg



