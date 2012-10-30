From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 30 Oct 2012 19:40:35 +0000 (UTC)
Subject: master - test: Check that overriding use_lvmetad with --config works.
Message-ID: <20121030194035.6678AA0DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09d77d0c9455a42bfe7c1c55ac64475fb349b1d6
Commit:        09d77d0c9455a42bfe7c1c55ac64475fb349b1d6
Parent:        983f0b46f2de85b8de0e2d7f8afbdf53f132a87a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 30 09:16:15 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 30 09:16:15 2012 +0100

test: Check that overriding use_lvmetad with --config works.

---
 test/shell/lvmetad-override.sh |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
new file mode 100644
index 0000000..3fb281a
--- /dev/null
+++ b/test/shell/lvmetad-override.sh
@@ -0,0 +1,25 @@
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
+lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
+kill $(cat LOCAL_LVMETAD)
+lvchange -ay $vg1 2>&1 | grep "Failed to connect"
+lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+lvchange -ay $vg1 --config 'global { use_lvmetad = 0 }' 2>&1 | not grep "Failed to connect"
+aux lvmconf "global/use_lvmetad = 0"
+lvchange -ay $vg1 --config 'global { use_lvmetad = 1 }' 2>&1 | grep "Failed to connect"
+


