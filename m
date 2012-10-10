From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Oct 2012 12:08:47 +0000 (UTC)
Subject: master - test: Check that lvmetad is refreshed correctly on restart.
Message-ID: <20121010120847.961C8A0D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f65754e6fc0e7e1eb17f058fe92db1ea6eead809
Commit:        f65754e6fc0e7e1eb17f058fe92db1ea6eead809
Parent:        71d718a4a4202d0e8a10bed1551878c68dd99a59
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 10 12:34:44 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 10 13:54:36 2012 +0200

test: Check that lvmetad is refreshed correctly on restart.

---
 test/shell/lvmetad-restart.sh |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
new file mode 100644
index 0000000..10268c2
--- /dev/null
+++ b/test/shell/lvmetad-restart.sh
@@ -0,0 +1,23 @@
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
+test -e LOCAL_LVMETAD || skip
+aux prepare_pvs 2
+
+vgcreate $vg1 $dev1 $dev2
+vgs | grep $vg1
+
+kill $(cat LOCAL_LVMETAD)
+aux prepare_lvmetad
+
+vgs | grep $vg1


