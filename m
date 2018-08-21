From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 21 Aug 2018 11:29:18 -0400
Subject: master - lvconvert: fix regression preventing direct striped conversion
Message-ID: <201808211529.w7LFTInS001435@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4578411633a40c8c9068ff439ef3c33cbe78d25a
Commit:        4578411633a40c8c9068ff439ef3c33cbe78d25a
Parent:        8b05f1f230517aa42878aa160d94383ed0534c64
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 21 17:12:33 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 21 17:28:56 2018 +0200

lvconvert: fix regression preventing direct striped conversion

Conversion to striped from raid0/raid0_meta is directly possible.

Fix a regression setting superfluous interim raid5_n conversion type
introduced by commit bd7cdd0b09ba123b064937fddde08daacbed7dab.

Add new test script lvconvert-raid0-striped.sh.

Resolves: rhbz1608067
---
 WHATS_NEW                             |    1 +
 lib/metadata/raid_manip.c             |    3 +++
 test/shell/lvconvert-raid0-striped.sh |   25 +++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a0b6e9..0ea2789 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Fix lvconvert raid0/raid0_meta -> striped regression.
   Fix lvconvert --splitmirror for mirror type (2.02.178).
   Do not pair cache policy and cache metadata format.
   lvconvert: reject conversions on raid1 LVs with split tracked SubLVs
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 931b411..5441527 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6126,6 +6126,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 		if (seg_from->area_count == 1)
 			seg_flag = SEG_RAID1;
 
+		else if (seg_is_any_raid0(seg_from) && segtype_is_striped(*segtype))
+			;
+
 		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
 		else if (((segtype_is_striped(*segtype) && !segtype_is_any_raid0(*segtype)) || segtype_is_any_raid5(*segtype)) &&
 			 !segtype_is_raid5_n(*segtype))
diff --git a/test/shell/lvconvert-raid0-striped.sh b/test/shell/lvconvert-raid0-striped.sh
new file mode 100644
index 0000000..4521b34
--- /dev/null
+++ b/test/shell/lvconvert-raid0-striped.sh
@@ -0,0 +1,25 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_raid 1 7 0 || skip
+
+aux prepare_vg 3 16
+
+lvcreate -aey --type raid0 -i 3 -l3 -n $lv $vg
+lvconvert -y --type striped $vg/$lv
+check lv_field $vg/$lv segtype "striped"
+vgremove -ff $vg


