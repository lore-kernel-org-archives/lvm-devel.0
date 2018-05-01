From: David Teigland <teigland@sourceware.org>
Date: Tue, 1 May 2018 16:26:36 -0400
Subject: master - tests: add gfs-pool test
Message-ID: <201805012026.w41KQa1r002395@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11436b00e0fa4a54ce504beba72b23bbf0682b27
Commit:        11436b00e0fa4a54ce504beba72b23bbf0682b27
Parent:        24e7745d7a54c6ef66cc76ebe2358a1bf2d3bd20
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 1 15:24:42 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 1 15:24:42 2018 -0500

tests: add gfs-pool test

Put back a test like the old one that was removed
in d709d8445f206b67cfc06266ce7553f9cb6f3df5.

It verifies that lvm will ignore and not use a
gfs-pool device.
---
 test/shell/pool-labels.sh |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
new file mode 100644
index 0000000..7ae203d
--- /dev/null
+++ b/test/shell/pool-labels.sh
@@ -0,0 +1,45 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# lvmetad does not handle pool labels so skip test.
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+env printf "" || skip # skip if printf is not available
+
+# create the old GFS pool labeled linear devices
+create_pool_label_()
+{
+  # FIXME
+  # echo -e is bashism, dash builtin sh doesn't do \xNN in printf either
+  # printf comes from coreutils, and is probably not posix either
+  env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of="$2" bs=5 seek=1 conv=notrunc
+  env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
+  aux notify_lvmetad "$2"
+}
+
+
+aux prepare_devs 2
+
+create_pool_label_ 0 "$dev1"
+create_pool_label_ 1 "$dev2"
+
+# verify that lvm will ignore and not use a gfs-pool device
+
+not pvs "$dev1"
+
+# check that pvcreate fails without -ff on the pool device
+not pvcreate "$dev1"
+


