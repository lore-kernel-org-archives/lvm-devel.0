From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Sep 2019 04:52:38 -0400
Subject: stable-2.02 - tests: allow-mixed-block-sizes
Message-ID: <201909240852.x8O8qchJ006899@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f758d16b30afd1848ea874b5ebd20185c5300320
Commit:        f758d16b30afd1848ea874b5ebd20185c5300320
Parent:        444dedea2355b42000f60b4ca0eb4a2f027123aa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 10:13:41 2019 -0500
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 24 10:48:39 2019 +0200

tests: allow-mixed-block-sizes

(cherry picked from commit cd8a0133fa28a0dff2714c80f822e8c665fe6237)
---
 test/shell/allow-mixed-block-sizes.sh |   44 +++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
new file mode 100644
index 0000000..1803256
--- /dev/null
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -0,0 +1,44 @@
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


