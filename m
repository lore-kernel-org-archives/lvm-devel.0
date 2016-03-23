From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed, 23 Mar 2016 11:00:48 +0000 (UTC)
Subject: master - test: Fix checks to skip lvmdbusd tests
Message-ID: <20160323110048.D1D6C60D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1d376b1abdb6b6a2410a5372a3a76748c1daa98
Commit:        c1d376b1abdb6b6a2410a5372a3a76748c1daa98
Parent:        c6d383a6da5cd7f5acddb314e1419243447e7be8
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 23 11:45:21 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 23 11:58:48 2016 +0100

test: Fix checks to skip lvmdbusd tests

The executable is always present in the tree, need to check the
runtime dependencies.
---
 test/lib/aux.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index af6b25a..ed1e3d8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -311,10 +311,12 @@ prepare_lvmdbusd() {
 	echo ok
 
 	# skip if we don't have our own lvmdbusd...
-        # TODO: lvmdbusd is not in PATH
-	#(which lvmdbusd 2>/dev/null | grep "$abs_builddir") || skip
+	# NOTE: this is always present - additional checks are needed:
 	[[ -x $abs_top_builddir/daemons/lvmdbusd/lvmdbusd ]] || skip
 
+	which python3 >/dev/null || skip "Missing python3"
+	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
+
 	kill_sleep_kill_ LOCAL_LVMDBUSD 0
 
 	echo "preparing lvmdbusd..."


