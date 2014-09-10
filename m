From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Sep 2014 17:57:14 +0000 (UTC)
Subject: master - lvmetad: Differentiate between filtered and truly missing devices.
Message-ID: <20140910175714.0A9AD602B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f1af9b99a0fb0824d8ab6b3b4c9ed3c61e89ee4
Commit:        4f1af9b99a0fb0824d8ab6b3b4c9ed3c61e89ee4
Parent:        1639bd2847ffc53352d8f74304403176b3807806
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 10 12:45:52 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 10 12:48:14 2014 +0200

lvmetad: Differentiate between filtered and truly missing devices.

We used to print an error message whenever we tried to deal with devices that
lvmetad knew about but were rejected by a client-side filter. Instead, we now
check whether the device is actually absent or only filtered out and only print
a warning in the latter case.
---
 lib/cache/lvmetad.c                 |    6 +++++-
 test/shell/lvmetad-client-filter.sh |   18 ++++++++++++++++++
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7896ddd..ef1d01a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -293,7 +293,11 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 		dev = dev_cache_get_by_devt(fallback, cmd->filter);
 
 	if (!dev) {
-		log_error("No device found for PV %s.", pvid_txt);
+		dev = dev_cache_get_by_devt(devt, cmd->lvmetad_filter);
+		if (!dev)
+			log_error("No device found for PV %s.", pvid_txt);
+		else
+			log_warn("WARNING: Device %s for PV %s rejected by a filter.", dev_name(dev), pvid_txt);
 		return NULL;
 	}
 
diff --git a/test/shell/lvmetad-client-filter.sh b/test/shell/lvmetad-client-filter.sh
new file mode 100644
index 0000000..3002a47
--- /dev/null
+++ b/test/shell/lvmetad-client-filter.sh
@@ -0,0 +1,18 @@
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
+. lib/inittest
+
+test -e LOCAL_LVMETAD || skip
+aux prepare_pvs 2
+
+pvs --config 'devices { filter = [ "r%.*%" ] }' 2>&1 | grep rejected
+pvs --config 'devices { filter = [ "r%.*%" ] }' 2>&1 | not grep 'No device found'


