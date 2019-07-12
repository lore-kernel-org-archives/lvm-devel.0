From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Jul 2019 16:04:20 -0400
Subject: master - tests: metadata-zero-space
Message-ID: <201907122004.x6CK4K9l029247@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbca70a0b7de682ce3f4547f313f55a9a44ed89d
Commit:        bbca70a0b7de682ce3f4547f313f55a9a44ed89d
Parent:        c22ad12bab1cff6fa4c23cb0242650751716803e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 12 14:08:22 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 12 15:03:47 2019 -0500

tests: metadata-zero-space

Test zero padding between copies of metadata.
---
 test/shell/metadata-zero-space.sh |   86 +++++++++++++++++++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
new file mode 100644
index 0000000..847ef44
--- /dev/null
+++ b/test/shell/metadata-zero-space.sh
@@ -0,0 +1,86 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 1 256
+get_devs
+
+# Fill with random data so if the space between metadata
+# copies are not zeroed the grep for zeros will fail.
+dd if=/dev/urandom of="$dev1" bs=1M || true
+
+pvcreate --pvmetadatacopies 2 "$dev1"
+
+vgcreate $SHARED "$vg" "$dev1"
+
+for i in `seq 1 50`; do lvcreate -l1 -an $vg; done
+
+if [ -e "/usr/bin/xxd" ]; then
+
+# Check metadata copies are separated by zeroes in the first mda
+
+dd if="$dev1" of=meta.raw bs=1M count=1
+
+xxd meta.raw > meta.txt
+
+grep -B1 "$vg {" meta.txt > meta.vg
+
+cat meta.vg
+
+grep -v $vg meta.vg > meta.zeros
+
+cat meta.zeros
+
+grep '0000 0000 0000 0000 0000 0000 0000 0000' meta.zeros > meta.count
+
+cat meta.count | wc -l
+
+# wc will often equal 51, but some natural variability in
+# metadata locations/content mean that some lines do not
+# require a full line of zero padding, and will not match
+# the grep for a full row of zeros.  So, check that more
+# than 20 lines match the full row of zeros (this is a
+# random choice, and this isn't a perfect way to test for
+# zero padding.)
+
+test "$(cat meta.count | wc -l)" -gt 20
+
+rm meta.raw meta.txt meta.vg meta.zeros meta.count
+
+#
+# Check metadata copies are separated by zeroes in the second mda
+#
+
+dd if="$dev1" of=meta.raw bs=1M seek=15 count=1
+
+xxd meta.raw > meta.txt
+
+grep -B1 "$vg {" meta.txt > meta.vg
+
+cat meta.vg
+
+grep -v $vg meta.vg > meta.zeros
+
+cat meta.zeros
+
+grep '0000 0000 0000 0000 0000 0000 0000 0000' meta.zeros > meta.count
+
+cat meta.count | wc -l
+
+test "$(cat meta.count | wc -l)" -gt 20
+
+fi
+
+vgremove -ff $vg


