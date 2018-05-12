From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:27:00 -0400
Subject: master - tests: add unit-test
Message-ID: <201805121627.w4CGR0oB008422@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c7565b65d0a02f6deedd37e1274b8646997fa71
Commit:        4c7565b65d0a02f6deedd37e1274b8646997fa71
Parent:        fa8d0b57660b9788d75b554eaeadb9725f522011
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 17:28:50 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

tests: add unit-test

Allow unit-test to be run as part of standard 'make check'.
---
 test/unit/unit-test.sh |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/test/unit/unit-test.sh b/test/unit/unit-test.sh
new file mode 100644
index 0000000..e8332d6
--- /dev/null
+++ b/test/unit/unit-test.sh
@@ -0,0 +1,23 @@
+#!/bin/sh
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_CLVMD=1
+
+SKIP_ROOT_DM_CHECK=1
+
+. lib/inittest
+
+aux unittest run


