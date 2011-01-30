From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:26 +0100
Subject: [PATCH 03/24] Test pv_min_size functionality
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <047a08486ee1ea87d0eb3abcb7ad798299ef0a64.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-pv-min-size.sh |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)
 create mode 100755 test/t-pv-min-size.sh

diff --git a/test/t-pv-min-size.sh b/test/t-pv-min-size.sh
new file mode 100755
index 0000000..71efcb6
--- /dev/null
+++ b/test/t-pv-min-size.sh
@@ -0,0 +1,31 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
+# use small default size  - 512KB
+aux lvmconf 'devices/pv_min_size = 512'
+
+aux prepare_pvs 1 8
+
+check pv_field $dev1 pv_name $dev1
+
+# increase min size beyond created PV size 10MB
+aux lvmconf 'devices/pv_min_size = 10240'
+
+# and test device is not visible
+not check pv_field $dev1 pv_name $dev1
+
+# set too low value errornous value
+aux lvmconf 'devices/pv_min_size = -100'
+
+# check the incorrect value is printed
+pvs $dev1 2>&1 | grep -- -100
-- 
1.7.3.5


