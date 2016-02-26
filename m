From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Feb 2016 09:22:50 +0000 (UTC)
Subject: master - tests: skip on older version
Message-ID: <20160226092250.C1CB960DCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=183bd8ca0342f6f72630afcb42b453b88ee90ac6
Commit:        183bd8ca0342f6f72630afcb42b453b88ee90ac6
Parent:        2988fa3c21cf84071446bc11cb61d5b8507c088c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 26 08:45:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 26 10:21:36 2016 +0100

tests: skip on older version

Skip with older driver version.
Update address.
---
 test/shell/dmstats-create.sh |    5 ++---
 test/shell/dmstats-report.sh |    8 +++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index d5db79f..028bec7 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -7,7 +7,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 . lib/inittest
 
@@ -24,4 +24,3 @@ dmstats create --start 0 --len 1 "$dev1"
 dmstats create --segments "$dev1"
 dmstats create --precise "$dev1"
 dmstats create --bounds 10ms,20ms,30ms "$dev1"
-
diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
index c36e3eb..702ea61 100644
--- a/test/shell/dmstats-report.sh
+++ b/test/shell/dmstats-report.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -7,10 +7,13 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 . lib/inittest
 
+# Don't attempt to test stats with driver < 4.33.00
+aux driver_at_least 4 33 || skip
+
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 1
 
@@ -21,4 +24,3 @@ dmstats create --bounds 10ms,20ms,30ms "$dev1"
 dmstats report
 dmstats report --count 1
 dmstats report --histogram
-


