From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Nov 2015 19:39:39 +0000 (UTC)
Subject: master - lvmetad: log duplicate PVs returned from lvmetad
Message-ID: <20151103193939.3965A60D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d30105f4712d83c89da2e82bb6f5d22dd599a94d
Commit:        d30105f4712d83c89da2e82bb6f5d22dd599a94d
Parent:        19feda2c95facee43ed1b470492e1d22e0f5dfdd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 15 10:50:27 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 3 13:35:51 2015 -0600

lvmetad: log duplicate PVs returned from lvmetad

When the command gets a list of alternate devices
from lvmetad, log each one directly.  This is not
the same as the warnings when adding lvmcache,
which are related to which duplicate is preferred.
---
 lib/cache/lvmetad.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 683c87c..c859413 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -439,6 +439,14 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 
 	while (alt_device) {
 		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
+
+		log_verbose("PV on device %s (%d:%d %d) is also on device %s (%d:%d %d) %s",
+			    dev_name(dev),
+			    (int)MAJOR(devt), (int)MINOR(devt), (int)devt,
+			    dev_alternate ? dev_name(dev_alternate) : "unknown",
+			    (int)MAJOR(alt_device->v.i), (int)MINOR(alt_device->v.i), (int)alt_device->v.i,
+			    pvid_txt);
+
 		if (dev_alternate) {
 			if ((info_alternate = lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
 							   vgname, (const char *)&vgid, 0))) {
@@ -446,9 +454,6 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 				info = info_alternate;
 				lvmcache_get_label(info)->dev = dev_alternate;
 			}
-		} else {
-			log_warn("Duplicate of PV %s dev %s exists on unknown device %"PRId64 ":%" PRId64,
-				 pvid_txt, dev_name(dev), MAJOR(alt_device->v.i), MINOR(alt_device->v.i));
 		}
 		alt_device = alt_device->next;
 	}


