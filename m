From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:46 +0000 (UTC)
Subject: master - tests: add template tests/shell/dmstats-create.sh
Message-ID: <20160225165146.1411660204@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d630ea78aa430608f914e6da37fb98b051d86fa
Commit:        2d630ea78aa430608f914e6da37fb98b051d86fa
Parent:        3dae4162293e385083025c85ec0e6307c48eb48e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Nov 27 17:57:33 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:58 2016 +0000

tests: add template tests/shell/dmstats-create.sh

Add a template for testing 'dmstats create' operations.
---
 test/shell/dmstats-create.sh |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
new file mode 100644
index 0000000..cb1671a
--- /dev/null
+++ b/test/shell/dmstats-create.sh
@@ -0,0 +1,20 @@
+#!/bin/sh
+# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
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
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+#aux prepare_devs 5
+
+# FIXME: some actual tests here.


