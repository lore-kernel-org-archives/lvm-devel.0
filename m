From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Feb 2022 23:01:44 +0000 (GMT)
Subject: main - tests: devicesfile-edit
Message-ID: <20220203230144.684CA3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=563105bba92f5a840d7d9f01acbc8be9daf39b32
Commit:        563105bba92f5a840d7d9f01acbc8be9daf39b32
Parent:        3fce6a81f82f2b2b1f75e5d49dbffc77bd637b3c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 3 16:58:12 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 3 16:58:12 2022 -0600

tests: devicesfile-edit

test lvmdevices add/del
---
 test/shell/devicesfile-edit.sh | 224 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 224 insertions(+)

diff --git a/test/shell/devicesfile-edit.sh b/test/shell/devicesfile-edit.sh
new file mode 100644
index 000000000..1675cb732
--- /dev/null
+++ b/test/shell/devicesfile-edit.sh
@@ -0,0 +1,224 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='devices file editing with lvmdevices'
+
+. lib/inittest
+
+aux lvmconf 'devices/scan = "/dev"'
+
+aux prepare_devs 1
+
+# The tests run with system dir of "/etc" but lvm when running
+# normally has cmd->system_dir set to "/etc/lvm".
+DFDIR="$LVM_SYSTEM_DIR/devices"
+mkdir -p "$DFDIR" || true
+DF="$DFDIR/system.devices"
+
+aux lvmconf 'devices/use_devicesfile = 1'
+
+losetup -h | grep sector-size || skip
+which fallocate || skip
+
+fallocate -l 2M loopa
+fallocate -l 2M loopb
+
+setup_loop_devs() {
+	for i in {1..5} ; do
+		LOOP1=$(losetup -f loopa --show || true)
+        	test -n "$LOOP1" && break
+	done
+	for i in {1..5} ; do
+        	LOOP2=$(losetup -f loopb --show || true)
+        	test -n "$LOOP2" && break
+	done
+}
+
+setup_loop_devs
+
+# Tests of devices without PV on them.
+
+# add/del with default idtype loop_file
+lvmdevices --adddev "$LOOP1"
+grep "$LOOP1" $DF
+lvmdevices --adddev "$LOOP2"
+grep "$LOOP2" $DF
+grep "IDTYPE=loop_file" $DF
+not grep "IDTYPE=devname" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+
+# add/del with non-default idtype devname
+lvmdevices --adddev "$LOOP1" --deviceidtype devname
+grep "$LOOP1" $DF
+lvmdevices --adddev "$LOOP2" --deviceidtype devname
+grep "$LOOP2" $DF
+grep "IDTYPE=devname" $DF
+not grep "IDTYPE=loop_file" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+
+# add/del when dev is missing, using default idtype
+lvmdevices --adddev "$LOOP1"
+grep "$LOOP1" $DF
+lvmdevices --adddev "$LOOP2"
+grep "$LOOP2" $DF
+losetup -D
+grep "$LOOP1" $DF
+grep "$LOOP2" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+not lvmdevices --adddev "$LOOP1"
+not lvmdevices --adddev "$LOOP2"
+not grep "$LOOP1" $DF
+not grep "$LOOP2" $DF
+setup_loop_devs
+rm $DF
+
+# add/del when dev is missing, using devname idtype
+lvmdevices --adddev "$LOOP1" --deviceidtype devname
+grep "$LOOP1" $DF
+lvmdevices --adddev "$LOOP2" --deviceidtype devname
+grep "$LOOP2" $DF
+losetup -D
+grep "$LOOP1" $DF
+grep "$LOOP2" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+setup_loop_devs
+rm $DF
+
+# Tests of devices with PV on them.
+
+touch $DF
+pvcreate "$LOOP1"
+pvcreate "$LOOP2"
+# PVID without dashes for matching devices file fields
+PVID1=`pvs "$LOOP1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$LOOP2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+# PVID with dashes for matching pvs -o+uuid output
+OPVID1=`pvs "$LOOP1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$LOOP2" --noheading -o uuid | awk '{print $1}'`
+grep "$LOOP1" $DF
+grep "$LOOP2" $DF
+grep "$PVID1" $DF
+grep "$PVID2" $DF
+rm $DF
+
+# add/deldev with default idtype loop_file
+lvmdevices --adddev "$LOOP1"
+grep "$LOOP1" $DF
+grep "$PVID1" $DF
+lvmdevices --adddev "$LOOP2"
+grep "$LOOP2" $DF
+grep "$PVID2" $DF
+grep "IDTYPE=loop_file" $DF
+not grep "IDTYPE=devname" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+
+# add/delpvid with default idtype loop_file
+lvmdevices --addpvid "$PVID1"
+grep "$LOOP1" $DF
+grep "$PVID1" $DF
+lvmdevices --addpvid "$PVID2"
+grep "$LOOP2" $DF
+grep "$PVID2" $DF
+grep "IDTYPE=loop_file" $DF
+not grep "IDTYPE=devname" $DF
+lvmdevices --delpvid "$PVID1"
+not grep "$LOOP1" $DF
+not grep "$PVID1" $DF
+lvmdevices --delpvid "$PVID2"
+not grep "$LOOP2" $DF
+not grep "$PVID2" $DF
+
+# add/deldev with non-default idtype devname
+lvmdevices --adddev "$LOOP1" --deviceidtype devname
+grep "$LOOP1" $DF
+grep "$PVID1" $DF
+lvmdevices --adddev "$LOOP2" --deviceidtype devname
+grep "$LOOP2" $DF
+grep "$PVID2" $DF
+grep "IDTYPE=devname" $DF
+not grep "IDTYPE=loop_file" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+
+# add/delpvid with non-default idtype devname
+lvmdevices --addpvid "$PVID1" --deviceidtype devname
+grep "$LOOP1" $DF
+grep "$PVID1" $DF
+lvmdevices --addpvid "$PVID2" --deviceidtype devname
+grep "$LOOP2" $DF
+grep "$PVID2" $DF
+grep "IDTYPE=devname" $DF
+not grep "IDTYPE=loop_file" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+
+# add/deldev when dev is missing, using default idtype
+lvmdevices --adddev "$LOOP1"
+grep "$LOOP1" $DF
+grep "$PVID1" $DF
+lvmdevices --adddev "$LOOP2"
+grep "$LOOP2" $DF
+grep "$PVID2" $DF
+losetup -D
+grep "$LOOP1" $DF
+grep "$LOOP2" $DF
+lvmdevices --deldev "$LOOP1"
+not grep "$LOOP1" $DF
+not grep "$PVID1" $DF
+lvmdevices --deldev "$LOOP2"
+not grep "$LOOP2" $DF
+not grep "$PVID2" $DF
+setup_loop_devs
+rm $DF
+
+# add/delpvid when dev is missing, using devname idtype
+lvmdevices --addpvid "$PVID1" --deviceidtype devname
+grep "$LOOP1" $DF
+grep "$PVID1" $DF
+lvmdevices --addpvid "$PVID2" --deviceidtype devname
+grep "$LOOP2" $DF
+grep "$PVID2" $DF
+losetup -D
+grep "$LOOP1" $DF
+grep "$LOOP2" $DF
+lvmdevices --delpvid "$PVID1"
+not grep "$LOOP1" $DF
+not grep "$PVID1" $DF
+lvmdevices --delpvid "$PVID2"
+not grep "$LOOP2" $DF
+not grep "$PVID2" $DF
+setup_loop_devs
+rm $DF
+
+# TODO: add/rem of partitions of same device
+
+losetup -D
+rm loopa loopb


