From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:33 +0000 (UTC)
Subject: master - raid: switch to log_warn
Message-ID: <20140702084833.8F00061054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c460f35cdadc853fc5bb7b796dbc0ead6968b82c
Commit:        c460f35cdadc853fc5bb7b796dbc0ead6968b82c
Parent:        355258be58fe52df0e90cb3831bc0e09f06d2e2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 1 09:53:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:34:40 2014 +0200

raid: switch to log_warn

Use log_warn for warning message.
log_error is printed when command returns error code.
---
 tools/lvconvert.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 28cbb32..3e00e17 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1914,10 +1914,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 
 		if (sync_percent != DM_PERCENT_100) {
-			log_error("WARNING: %s/%s is not in-sync.",
-				  lv->vg->name, lv->name);
-			log_error("WARNING: Portions of the array may"
-				  " be unrecoverable.");
+			log_warn("WARNING: %s/%s is not in-sync.",
+				 lv->vg->name, lv->name);
+			log_warn("WARNING: Portions of the array may be unrecoverable.");
 
 			/*
 			 * The kernel will not allow a device to be replaced


