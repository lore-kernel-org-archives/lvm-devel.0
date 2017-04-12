From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 17:06:38 -0400
Subject: master - raid: use log_error
Message-ID: <201704122106.v3CL6cgD024321@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e64386dc69a0e13404eefc2deb0c3908632457c
Commit:        1e64386dc69a0e13404eefc2deb0c3908632457c
Parent:        1f715ab3b20f3e2589fa547428e84134349465da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 12 23:05:09 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 23:05:50 2017 +0200

raid: use log_error

Turn log_print into log_error for error path.
---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 35f7fa5..34ac2a6 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2225,8 +2225,8 @@ static int _raid_reshape(struct logical_volume *lv,
 		log_print_unless_silent("No change in RAID LV %s layout, freeing reshape space.", display_lvname(lv));
 
 		if (where_it_was == alloc_none) {
-			log_print_unless_silent("LV %s does not have reshape space allocated.",
-						display_lvname(lv));
+			log_error("LV %s does not have reshape space allocated.",
+				  display_lvname(lv));
 			return 0;
 		}
 


