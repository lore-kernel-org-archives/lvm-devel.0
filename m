From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 30 Jul 2014 14:18:35 +0000 (UTC)
Subject: master - test: Add a test for lvextend -l+100%FREE of a striped thin pool.
Message-ID: <20140730141835.A366160254@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4484d90503c4e5c2bc945461da50a6b85c5d7e7
Commit:        c4484d90503c4e5c2bc945461da50a6b85c5d7e7
Parent:        321bed713727a81d743b42c98c1fd91c18ecddb5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jul 30 16:15:16 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jul 30 16:17:29 2014 +0200

test: Add a test for lvextend -l+100%FREE of a striped thin pool.

---
 test/shell/lvextend-thin.sh |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
new file mode 100644
index 0000000..0d5a2f5
--- /dev/null
+++ b/test/shell/lvextend-thin.sh
@@ -0,0 +1,17 @@
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
+aux prepare_vg 3
+lvcreate -i2 -l2 -T $vg/pool2
+lvextend -l+2 $vg/pool2 $dev2 $dev3
+should lvextend -l+100%FREE $vg/pool2


