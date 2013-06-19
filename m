From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 Jun 2013 11:24:33 +0200
Subject: [PATCH 3/9] test: Add a test for the failing pv_read optimisation.
In-Reply-To: <1371633879-8879-1-git-send-email-prockai@redhat.com>
References: <1371633879-8879-1-git-send-email-prockai@redhat.com>
Message-ID: <1371633879-8879-3-git-send-email-prockai@redhat.com>
	(sfid-20130619_112441_241702_C1683F5F)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 test/shell/pvread-bogosity.sh | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 test/shell/pvread-bogosity.sh

diff --git a/test/shell/pvread-bogosity.sh b/test/shell/pvread-bogosity.sh
new file mode 100644
index 0000000..d47eb8a
--- /dev/null
+++ b/test/shell/pvread-bogosity.sh
@@ -0,0 +1,26 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+aux prepare_devs 3
+
+vgcreate --metadatasize 128k $vg1 "$dev1" "$dev2" "$dev3"
+
+vgreduce $vg1 $dev1
+dd if="$dev1" of=badmda bs=256K count=1
+vgextend $vg1 $dev1
+
+dd if=badmda of="$dev1" bs=256K count=1
+
+# dev1 is part of vg1 (as witnessed by metadata on dev2 and dev3), but its mda
+# was corrupt (written over by a backup from time dev1 was an orphan)
+check pv_field $dev1 vg_name $vg1
-- 
1.8.2


