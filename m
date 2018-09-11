From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Sep 2018 14:55:55 -0400
Subject: master - tests: add metadata-full
Message-ID: <201809111855.w8BIttR2019938@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17bd91e33e0d37d8cca03b42cee20251d7fa5e80
Commit:        17bd91e33e0d37d8cca03b42cee20251d7fa5e80
Parent:        5fb15b19349af607654f2429850a706bbac4b792
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 11 10:05:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 11 12:05:46 2018 -0500

tests: add metadata-full

---
 test/shell/metadata-full.sh |   96 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/test/shell/metadata-full.sh b/test/shell/metadata-full.sh
new file mode 100644
index 0000000..388ebcd
--- /dev/null
+++ b/test/shell/metadata-full.sh
@@ -0,0 +1,96 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test full metadata'
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+LVM_TEST_PVS=${LVM_TEST_PVS:-64}
+
+# aux prepare_vg $LVM_TEST_PVS
+
+unset LVM_LOG_FILE_MAX_LINES
+
+aux prepare_devs 64
+get_devs
+
+vgcreate $SHARED -s 512K --metadatacopies 8 $vg "${DEVICES[@]}"
+
+# have tested to see how many LVs can be created in a
+# vg set up like this and it's around 1190, so pick a
+# number less than that but over 1024 (in case there's
+# some issue at the number 1024 we want to find it.)
+#
+# uses long tags to increase the size of the metadata
+# more quickly
+#
+# the specific number of LVs in these loops isn't great
+# because it doesn't depend specified behavior, but it's
+# based on how much metadata it produces at the time this
+# is written.
+
+
+for i in `seq 1 1050`; do lvcreate -l1 -an --addtag A123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg; done
+
+# should show non-zero
+vgs -o+pv_mda_free
+
+# these addtag's will fail at some point when metadata space is full
+
+for i in `seq 1 1050`; do lvchange --addtag B123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg/lvol$i || true; done
+
+# should show 0
+vgs -o+pv_mda_free
+check vg_field $vg vg_mda_free 0
+
+# remove some of the tags to check that we can reduce the size of the
+# metadata, and continue using the vg
+
+for i in `seq 1 50`; do lvchange --deltag B123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg/lvol$i || true; done
+
+# should show non-zero
+vgs -o+pv_mda_free
+
+# these will fail at some point when metadata space is full again
+
+for i in `seq 1 50`; do lvcreate -l1 -an --addtag C123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg || true; done
+
+# should show 0
+vgs -o+pv_mda_free
+check vg_field $vg vg_mda_free 0
+
+# as long as we have a lot of LVs around, try to activate them all
+# (filters are already set up that exclude the activated LVs from
+# being scanned)
+
+time vgs
+
+vgchange -ay $vg
+
+time vgs
+
+vgchange -an $vg
+
+# see if we can remove LVs to make more metadata space,
+# and then create more LVs
+
+for i in `seq 1 50`; do lvremove -y $vg/lvol$i; done
+
+for i in `seq 1 10`; do lvcreate -l1 $vg; done
+
+# should show non-zero
+vgs -o+pv_mda_free
+
+vgremove -ff $vg
+


