From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:02:01 +0000 (UTC)
Subject: master - TEST: Add a regression test for the ondisk/orphan bug.
Message-ID: <20130722100201.EFF786136E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd60232d7428a8b51c8794b30503761f4032f7a1
Commit:        bd60232d7428a8b51c8794b30503761f4032f7a1
Parent:        f897fcbd957517b484956062055599b226090f05
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 11:57:23 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jul 22 11:57:23 2013 +0200

TEST: Add a regression test for the ondisk/orphan bug.

---
 test/shell/orphan-ondisk.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
new file mode 100644
index 0000000..2a820d6
--- /dev/null
+++ b/test/shell/orphan-ondisk.sh
@@ -0,0 +1,15 @@
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
+aux prepare_vg 2
+vgreduce $vg $dev1 2>&1 | not grep -i 'parse error'


