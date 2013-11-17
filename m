From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:31 +0000 (UTC)
Subject: master - test: Add a test for the failing pv_read optimisation.
Message-ID: <20131117222631.6C44460DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a59305c44e992831d66da50f5058f154a795d3a
Commit:        0a59305c44e992831d66da50f5058f154a795d3a
Parent:        7e685e6c70e5b738e5740b920e6080b9a13c2556
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jun 11 09:13:39 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:26 2013 +0100

test: Add a test for the failing pv_read optimisation.

---
 test/shell/mda-rollback.sh |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
new file mode 100644
index 0000000..d47eb8a
--- /dev/null
+++ b/test/shell/mda-rollback.sh
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


