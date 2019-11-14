From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:10 -0500
Subject: master - cov: add explicit ret value ignoring
Message-ID: <34182.119111412080601617@us-mta-230.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33c1d2e92137876116fd81cdca61874cc8e299c7
Commit:        33c1d2e92137876116fd81cdca61874cc8e299c7
Parent:        ad0343d8cb9644912961a72760df083378104078
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:11:01 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: add explicit ret value ignoring

We don't need to check for any error result codes here.
---
 lib/metadata/thin_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index f947976..0704f2b 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -503,11 +503,11 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 			 *   which Node has pool active.
 			 */
 			if (!activate_lv(lv->vg->cmd, lv)) {
-				init_dmeventd_monitor(monitored);
+				(void) init_dmeventd_monitor(monitored);
 				return_0;
 			}
 			if (!lv_is_active(lv)) {
-				init_dmeventd_monitor(monitored);
+				(void) init_dmeventd_monitor(monitored);
 				log_error("Cannot activate thin pool %s, perhaps skipped in lvm.conf volume_list?",
 					  display_lvname(lv));
 				return 0;



