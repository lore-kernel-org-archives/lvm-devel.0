From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 22 Jul 2013 13:06:12 +0000 (UTC)
Subject: master - pvscan: Respect lvmetad (global) filter in --cache w/ a device.
Message-ID: <20130722130612.481FD61020@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fdb45d0402ac9b404f4277d7954043ea257f019
Commit:        3fdb45d0402ac9b404f4277d7954043ea257f019
Parent:        ea333a894e93f665a515986fdebf2a6c9e10d42a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 15:03:56 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jul 22 15:05:39 2013 +0200

pvscan: Respect lvmetad (global) filter in --cache w/ a device.

---
 test/shell/lvmetad-pvscan-filter.sh |   29 +++++++++++++++++++++++++++++
 tools/pvscan.c                      |    5 ++---
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
new file mode 100644
index 0000000..5dd66c4
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -0,0 +1,29 @@
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
+
+aux prepare_pvs 2
+
+maj=$(($(stat --printf=0x%t "$dev2")))
+min=$(($(stat --printf=0x%T "$dev2")))
+
+aux hide_dev $dev2
+not pvscan --cache $dev2 2>&1 | grep "not found"
+# pvscan with --major/--minor does not fail (for udev's sake?)
+pvscan --cache --major $maj --minor $min 2>&1 | grep "not found"
+aux unhide_dev $dev2
+
+pvscan --cache $dev2 2>&1 | not grep "not found"
+pvscan --cache --major $maj --minor $min 2>&1 | not grep "not found"
+pvs | grep $dev2
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 63dc524..96bbf6b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -187,7 +187,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	/* Process any command line PVs first. */
 	while (argc--) {
 		pv_name = *argv++;
-		dev = dev_cache_get(pv_name, NULL);
+		dev = dev_cache_get(pv_name, cmd->lvmetad_filter);
 		if (!dev) {
 			log_error("Physical Volume %s not found.", pv_name);
 			ret = ECMD_FAILED;
@@ -218,10 +218,9 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 
 		devno = MKDEV((dev_t)major, minor);
 
-		if (!(dev = dev_cache_get_by_devt(devno, NULL))) {
+		if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
 			if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
 				stack;
-			/* FIXME Filters? */
 			if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
 				ret = ECMD_FAILED;
 				if (buf)


