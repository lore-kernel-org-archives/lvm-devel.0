From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  4 Aug 2014 15:06:37 +0000 (UTC)
Subject: master - test: Add a test for lvscan --cache.
Message-ID: <20140804150637.3E06D60BC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03a88da86895f4700edf77af4efde62a30e67bff
Commit:        03a88da86895f4700edf77af4efde62a30e67bff
Parent:        54685c20fc9dfb155a2e5bc9d8cf5f0aad944305
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 4 17:00:34 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Aug 4 17:03:17 2014 +0200

test: Add a test for lvscan --cache.

---
 test/shell/lvmetad-lvscan-cache.sh |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
new file mode 100644
index 0000000..529753c
--- /dev/null
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -0,0 +1,32 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+test -e LOCAL_LVMETAD || skip
+
+aux prepare_pvs 2
+
+vgcreate $vg1 $dev1 $dev2
+lvcreate -n testlv -m 1 -l 1 $vg1
+vgs | grep $vg1
+
+lvscan --cache $vg1/testlv
+
+vgs | grep $vg1
+
+aux disable_dev $dev2
+
+# pvscan --cache already ran for the disabled device above, this should be a
+# no-op (but should not segfault!)
+lvscan --cache $vg1/testlv
+
+vgremove -ff $vg1


