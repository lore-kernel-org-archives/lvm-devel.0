From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  7 Oct 2012 20:33:12 +0000 (UTC)
Subject: master - TEST: Add lvmetad-pvscan-cache to check that pvscan --cache works.
Message-ID: <20121007203312.C993AA0DA9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7020732354eef05e3e1bda9c5bdf49788e49130
Commit:        e7020732354eef05e3e1bda9c5bdf49788e49130
Parent:        7f4f7f70ce94e9692b84a3568aedfceb13466ece
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Oct 7 22:31:33 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Oct 7 22:32:32 2012 +0200

TEST: Add lvmetad-pvscan-cache to check that pvscan --cache works.

---
 test/shell/lvmetad-pvscan-cache.sh |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
new file mode 100644
index 0000000..be95b38
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -0,0 +1,21 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+aux prepare_pvs 2
+
+vgcreate $vg1 $dev1 $dev2
+vgs | grep $vg1
+
+pvscan --cache
+
+vgs | grep $vg1


