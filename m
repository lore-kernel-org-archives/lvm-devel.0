From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 17:03:30 -0400
Subject: master - raid: allow more sync action for extraction
Message-ID: <201706242103.v5OL3Ux1031825@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c465ca6a3acd2b01ddacac2275bd965bde2b4167
Commit:        c465ca6a3acd2b01ddacac2275bd965bde2b4167
Parent:        cac9e0b681feaf71f59ecf4f41ef724129ad61d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 22:28:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 22:28:25 2017 +0200

raid: allow more sync action for extraction

Since we discovered status reporting from 'md' goes from large set
of weird states we can't just decided based on this word.
So let it pass for rebuild and idle as well
and check for health devices afterwards.
---
 lib/metadata/raid_manip.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2a427ab..2d735ed 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2886,17 +2886,14 @@ static int _raid_allow_extraction(struct logical_volume *lv,
 	    !lv_raid_dev_health(lv, &dev_health))
 		return_0;
 
-	if (!strcmp("idle", sync_action)) {
-		log_error(INTERNAL_ERROR
-			  "RAID LV should not be out-of-sync and \"idle\"");
-		return 0;
-	}
-
 	if (!strcmp("resync", sync_action))
 		return 1;
 
-	/* If anything other than "recover" */
-	if (strcmp("recover", sync_action)) {
+	/* If anything other than "recover", rebuild or "idle" */
+        /* Targets reports for a while 'idle' state, before recover starts */
+	if (strcmp("recover", sync_action) &&
+	    strcmp("rebuild", sync_action) &&
+	    strcmp("idle", sync_action)) {
 		log_error("Unable to remove RAID image while array"
 			  " is performing \"%s\"", sync_action);
 		return 0;


