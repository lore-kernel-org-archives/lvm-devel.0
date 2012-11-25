From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 25 Nov 2012 21:28:54 +0000 (UTC)
Subject: master - Automatically restore MISSING PVs with no MDAs.
Message-ID: <20121125212854.2955CA105C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60668f823e830ce39e452234996910c51728aa76
Commit:        60668f823e830ce39e452234996910c51728aa76
Parent:        b3e9a09abefde12be2031235275f11d4a53dea11
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 25 20:41:56 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 25 20:41:56 2012 +0100

Automatically restore MISSING PVs with no MDAs.

---
 WHATS_NEW                          |    1 +
 lib/format_text/import_vsn1.c      |    6 ++++++
 test/shell/nomda-restoremissing.sh |   31 +++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0904940..2ea3f2b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Automatically restore MISSING PVs with no MDAs.
   When no '-i' argument is given for RAID10, default to 2 stripes.
   Do not allow --splitmirrors on RAID10 logical volumes.
   Skip mlocking [vectors] on arm architecture.
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index dff70f7..e73c475 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -221,6 +221,12 @@ static int _read_pv(struct format_instance *fid,
 	if (!pv->dev && !lvmetad_active())
 		pv->status |= MISSING_PV;
 
+	if ((pv->status & MISSING_PV) && pv->dev && pv_mda_used_count(pv) == 0) {
+		pv->status &= ~MISSING_PV;
+		log_info("Recovering a previously MISSING PV %s with no MDAs.",
+			 pv_dev_name(pv));
+	}
+
 	/* Late addition */
 	if (dm_config_has_node(pvn, "dev_size") &&
 	    !_read_uint64(pvn, "dev_size", &pv->size)) {
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
new file mode 100644
index 0000000..8dd71fa
--- /dev/null
+++ b/test/shell/nomda-restoremissing.sh
@@ -0,0 +1,31 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 3
+
+pvchange --metadataignore y $dev1
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+lvcreate -l 1 -n lv1 $vg "$dev1"
+
+# try to just change metadata; we expect the new version (with MISSING_PV set
+# on the reappeared volume) to be written out to the previously missing PV
+aux disable_dev "$dev1"
+lvremove $vg/mirror
+not vgck $vg 2>&1 | tee log
+grep "missing 1 physical volume" log
+not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
+aux enable_dev "$dev1"
+lvcreate -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
+vgck $vg


