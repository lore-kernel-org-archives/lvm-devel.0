From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Jun 2019 14:59:00 -0400
Subject: master - tests: pvck-dump
Message-ID: <201906051859.x55Ix0KI025940@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=356ea897ccfca5a80b00a0a6b2479042f6efd144
Commit:        356ea897ccfca5a80b00a0a6b2479042f6efd144
Parent:        bada89a224b0135ac4415d43e6b128989bbf3b2b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 5 13:58:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 5 13:58:26 2019 -0500

tests: pvck-dump

---
 test/shell/pvck-dump.sh |  119 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
new file mode 100644
index 0000000..ed8766a
--- /dev/null
+++ b/test/shell/pvck-dump.sh
@@ -0,0 +1,119 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013,2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+. lib/inittest
+
+aux prepare_devs 3
+get_devs
+
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+dd if=/dev/zero of="$dev3" || true
+
+pvcreate "$dev1"
+pvcreate "$dev2"
+pvcreate --pvmetadatacopies 2 "$dev3"
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+
+pvck --dump headers "$dev1" > h1
+pvck --dump headers "$dev2" > h2
+pvck --dump headers "$dev3" > h3
+
+grep "label_header at 512" h1
+grep "label_header at 512" h2
+grep "label_header at 512" h3
+
+grep "pv_header at 544" h1
+grep "pv_header at 544" h2
+grep "pv_header at 544" h3
+
+grep "pv_header.disk_locn\[0\].offset 1048576" h1
+grep "pv_header.disk_locn\[0\].offset 1048576" h2
+grep "pv_header.disk_locn\[0\].offset 1048576" h3
+
+grep "pv_header.disk_locn\[2\].offset 4096" h1
+grep "pv_header.disk_locn\[2\].offset 4096" h2
+grep "pv_header.disk_locn\[2\].offset 4096" h3
+
+grep "pv_header.disk_locn\[2\].size 1044480" h1
+grep "pv_header.disk_locn\[2\].size 1044480" h2
+grep "pv_header.disk_locn\[2\].size 1044480" h3
+
+grep "mda_header_1 at 4096" h1
+grep "mda_header_1 at 4096" h2
+grep "mda_header_1 at 4096" h3
+
+grep "mda_header_1.start 4096" h1
+grep "mda_header_1.start 4096" h2
+grep "mda_header_1.start 4096" h3
+
+grep "mda_header_1.size 1044480" h1
+grep "mda_header_1.size 1044480" h2
+grep "mda_header_1.size 1044480" h3
+
+grep "mda_header_2 at " h3
+grep "mda_header_2.start " h3
+
+grep "metadata text at " h1
+grep "metadata text at " h2
+grep "metadata text at " h3
+
+not grep CHECK h1
+not grep CHECK h2
+not grep CHECK h3
+
+pvck --dump metadata "$dev1" > m1
+pvck --dump metadata "$dev2" > m2
+pvck --dump metadata "$dev3" > m3
+pvck --dump metadata --pvmetadatacopies 2 "$dev3" > m3b
+
+diff m1 m2
+diff m1 m3
+
+not diff m1 m3b > tmp
+grep "metadata text at" tmp
+
+lvcreate -an -l1 $vg
+
+pvck --dump metadata_all -f all1 "$dev1" > out1
+pvck --dump metadata_all -f all2 "$dev2" > out2
+pvck --dump metadata_all -f all3 "$dev3" > out3
+pvck --dump metadata_all --pvmetadatacopies 2 -f all3b "$dev3" > out3b
+
+diff out1 out2
+diff out1 out3
+
+grep "seqno 1 with" out1
+grep "seqno 1 with" out3b
+grep "seqno 2 with" out1
+grep "seqno 2 with" out3b
+
+diff all1 all2
+diff all1 all3
+diff all1 all3b
+
+grep "seqno = 1" all1
+grep "seqno = 2" all1
+
+
+pvck --dump metadata_area -f area1 "$dev1"
+pvck --dump metadata_area -f area2 "$dev2"
+pvck --dump metadata_area -f area3 "$dev3"
+pvck --dump metadata_area -f area3b "$dev3"
+
+diff area1 area2
+diff area1 area3
+diff area1 area3b
+
+vgremove -ff $vg
+


