From: David Teigland <teigland@sourceware.org>
Date: Wed, 23 Oct 2019 14:28:56 -0400
Subject: stable-2.02 - tests: remove allow-mixed-block-sizes
Message-ID: <201910231828.x9NISufM011347@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e99308b7cab21fd79d1290a5aa47aee4ee4a76e
Commit:        4e99308b7cab21fd79d1290a5aa47aee4ee4a76e
Parent:        c37aa7881d840c429b858ee0068f0151e46ce0d9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 23 13:26:19 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 23 13:26:19 2019 -0500

tests: remove allow-mixed-block-sizes

---
 test/shell/allow-mixed-block-sizes.sh |   46 ---------------------------------
 1 files changed, 0 insertions(+), 46 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
deleted file mode 100644
index 2f0b3a0..0000000
--- a/test/shell/allow-mixed-block-sizes.sh
+++ /dev/null
@@ -1,46 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-losetup -h | grep sector-size || skip
-
-dd if=/dev/zero of=loopa bs=$((1024*1024)) count=2 2> /dev/null
-dd if=/dev/zero of=loopb bs=$((1024*1024)) count=2 2> /dev/null
-LOOP1=$(losetup -f loopa --sector-size 4096 --show)
-LOOP2=$(losetup -f loopb --show)
-
-echo $LOOP1
-echo $LOOP2
-
-aux extend_filter "a|$LOOP1|"
-aux extend_filter "a|$LOOP2|"
-
-not vgcreate --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOOP1 $LOOP2
-vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1 $LOOP2
-vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
-
-wipefs -a $LOOP1
-wipefs -a $LOOP2
-
-vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1
-vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
-not vgextend --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOOP2
-vgextend --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP2
-
-losetup -d $LOOP1
-losetup -d $LOOP2
-rm loopa
-rm loopb
-


