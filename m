From: Petr Rockai <prockai@redhat.com>
Date: Mon, 15 Dec 2014 23:32:39 +0100
Subject: [PATCH 3/4] test: Add a test for reports of cache policy & settings.
In-Reply-To: <1418682760-16427-1-git-send-email-prockai@redhat.com>
References: <1418682760-16427-1-git-send-email-prockai@redhat.com>
Message-ID: <1418682760-16427-3-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 test/shell/lvs-cache.sh | 50 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)
 create mode 100644 test/shell/lvs-cache.sh

diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
new file mode 100644
index 0000000..6ac5d0d
--- /dev/null
+++ b/test/shell/lvs-cache.sh
@@ -0,0 +1,50 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Exercise creation of cache and cache pool volumes
+
+# Full CLI uses  --type
+# Shorthand CLI uses -H | --cache
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+aux prepare_vg 5 8000
+
+lvcreate --type cache-pool -L10 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+lvs -a -o lv_name,cache_policy
+lvs -a -o lv_name,cache_settings
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq \
+	 --cachesettings migration_threshold=233
+lvs -a -o lv_name,cache_policy   | grep mq
+lvs -a -o lv_name,cache_settings | grep migration_threshold=233
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+lvs -a -o lv_name,cache_policy   | grep mq
+lvs -a -o lv_name,cache_settings | grep migration_threshold=233
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+lvs -a -o lv_name,cache_policy   | grep mq
+lvs -a -o lv_name,cache_settings | grep migration_threshold=233
+lvs -a -o lv_name,cache_settings | grep sequential_threshold=13
+
+lvremove -f $vg
-- 
2.1.2


