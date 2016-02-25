From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:54 +0000 (UTC)
Subject: master - tests: add simple dmstats report tests
Message-ID: <20160225165154.6E5C860D3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79f259621542e62a2f9fb5982f473d2bb849b1b5
Commit:        79f259621542e62a2f9fb5982f473d2bb849b1b5
Parent:        3d3b132d9ac845e31c316ad4b908466bb3837a4d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Feb 18 16:52:37 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:59 2016 +0000

tests: add simple dmstats report tests

Add tests for the "dmstats report" command:

  * report
  * report --count
  * report --histogram

So far the tests just check the command runs as expected when a
correctly configured stats region exists: validation of output
can be added later.
---
 test/shell/dmstats-report.sh |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
new file mode 100644
index 0000000..c36e3eb
--- /dev/null
+++ b/test/shell/dmstats-report.sh
@@ -0,0 +1,24 @@
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
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+# prepare a stats region with a histogram
+dmstats create --bounds 10ms,20ms,30ms "$dev1"
+
+# basic dmstats report commands
+dmstats report
+dmstats report --count 1
+dmstats report --histogram
+


