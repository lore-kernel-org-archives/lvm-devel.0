From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Oct 2019 11:27:33 -0400
Subject: stable-2.02 - Revert "tests: remove allow-mixed-block-sizes"
Message-ID: <201910241527.x9OFRXCf001375@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e298a87f71927987c2c324e2a53e1b4cd840f186
Commit:        e298a87f71927987c2c324e2a53e1b4cd840f186
Parent:        c2853147639ca31f16539a4e6316ef3320811497
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 10:12:10 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 24 10:26:28 2019 -0500

Revert "tests: remove allow-mixed-block-sizes"

This reverts commit 4e99308b7cab21fd79d1290a5aa47aee4ee4a76e.
---
 test/shell/allow-mixed-block-sizes.sh |   46 +++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
new file mode 100644
index 0000000..2f0b3a0
--- /dev/null
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -0,0 +1,46 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
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
+losetup -h | grep sector-size || skip
+
+dd if=/dev/zero of=loopa bs=$((1024*1024)) count=2 2> /dev/null
+dd if=/dev/zero of=loopb bs=$((1024*1024)) count=2 2> /dev/null
+LOOP1=$(losetup -f loopa --sector-size 4096 --show)
+LOOP2=$(losetup -f loopb --show)
+
+echo $LOOP1
+echo $LOOP2
+
+aux extend_filter "a|$LOOP1|"
+aux extend_filter "a|$LOOP2|"
+
+not vgcreate --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOOP1 $LOOP2
+vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1 $LOOP2
+vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
+
+wipefs -a $LOOP1
+wipefs -a $LOOP2
+
+vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1
+vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
+not vgextend --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOOP2
+vgextend --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP2
+
+losetup -d $LOOP1
+losetup -d $LOOP2
+rm loopa
+rm loopb
+


