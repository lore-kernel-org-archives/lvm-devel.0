From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Oct 2012 12:08:45 +0000 (UTC)
Subject: master - lvmetad: Warn if lvmetad is running but disabled.
Message-ID: <20121010120845.53649A0D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71d718a4a4202d0e8a10bed1551878c68dd99a59
Commit:        71d718a4a4202d0e8a10bed1551878c68dd99a59
Parent:        622fb968a22d5b2c6ba3dcd9155743adfe5dec8c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 10 12:33:48 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 10 13:54:29 2012 +0200

lvmetad: Warn if lvmetad is running but disabled.

---
 lib/cache/lvmetad.c            |    2 ++
 test/Makefile.in               |    1 +
 test/shell/lvmetad-disabled.sh |   26 ++++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b5fdc54..b5e3787 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -41,6 +41,8 @@ void lvmetad_disconnect(void)
 
 void lvmetad_init(struct cmd_context *cmd)
 {
+	if (!_lvmetad_use && !access(LVMETAD_PIDFILE, F_OK))
+		log_warn("WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!");
 	if (_lvmetad_use && _lvmetad_socket && !_lvmetad_connected) {
 		assert(_lvmetad_socket);
 		_lvmetad = lvmetad_open(_lvmetad_socket);
diff --git a/test/Makefile.in b/test/Makefile.in
index 6d7ee2c..5bbd1d6 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -99,6 +99,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	echo 'export THIN=@THIN@' >> $@-t
+	echo 'export LVMETAD_PIDFILE=@LVMETAD_PIDFILE@' >> $@-t
 	mv $@-t $@
 
 LIB = lib/not lib/should lib/harness \
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
new file mode 100644
index 0000000..41a3a19
--- /dev/null
+++ b/test/shell/lvmetad-disabled.sh
@@ -0,0 +1,26 @@
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
+kill $(cat LOCAL_LVMETAD)
+
+test -e $LVMETAD_PIDFILE && skip
+lvmetad
+test -e $LVMETAD_PIDFILE
+cp $LVMETAD_PIDFILE LOCAL_LVMETAD
+pvs 2>&1 | not grep "lvmetad is running"
+aux lvmconf "global/use_lvmetad = 0"
+pvs 2>&1 | grep "lvmetad is running"
+
+kill $(cat $LVMETAD_PIDFILE)
+not ls $LVMETAD_PIDFILE


