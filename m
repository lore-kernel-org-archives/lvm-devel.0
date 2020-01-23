From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Jan 2020 04:32:56 -0500
Subject: master - tests: add corruption write on PV test
Message-ID: <11696.120012304324800271@us-mta-9.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bab3b70e3ae253da39da6fb9146ccf428cdb6ab3
Commit:        bab3b70e3ae253da39da6fb9146ccf428cdb6ab3
Parent:        ecb77e9db31c88ed1a53e3194366e642f9b04e5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 20 14:16:13 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 10:32:15 2020 +0100

tests: add corruption write on PV test

Test a case where PV is readable, but fails on write updating.
Check the failure is reported only for a single PV.
---
 test/shell/pv-corruption.sh | 56 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/test/shell/pv-corruption.sh b/test/shell/pv-corruption.sh
new file mode 100644
index 0000000..b3c5059
--- /dev/null
+++ b/test/shell/pv-corruption.sh
@@ -0,0 +1,56 @@
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
+# skip test early if there is no 'delay' target available
+aux target_at_least dm-delay 1 1 0 || skip "missing dm-delay target"
+touch HAVE_DM_DELAY
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



