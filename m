From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:27 +0100
Subject: [PATCH 03/15] Test pv_min_size functionality
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <7ff95ae9abbee08dcc0c9be39f281f6e9e099aaf.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-pv-min-size.sh |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)
 create mode 100755 test/t-pv-min-size.sh

diff --git a/test/t-pv-min-size.sh b/test/t-pv-min-size.sh
new file mode 100755
index 0000000..c1f941c
--- /dev/null
+++ b/test/t-pv-min-size.sh
@@ -0,0 +1,25 @@
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
-- 
1.7.3.5


