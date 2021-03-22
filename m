From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:30 +0000 (GMT)
Subject: dev-next - raid: resync cannot lose primary leg
Message-ID: <20210322153930.13BC0385480A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc140f68a505aad117a6e8222f65a5ea13139083
Commit:        cc140f68a505aad117a6e8222f65a5ea13139083
Parent:        076e1556978dfb216176d319d2498ec571fcc908
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 01:54:06 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:19:31 2021 +0100

raid: resync cannot lose primary leg

Prohibity droping primary leg while resyncing.
---
 lib/metadata/raid_manip.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index dc3bce201..33fd017cb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2945,11 +2945,16 @@ static int _raid_allow_extraction(struct logical_volume *lv,
 	    !lv_raid_dev_health(lv, &dev_health))
 		return_0;
 
-	if (!strcmp("resync", sync_action))
-		return 1;
+	if (!strcmp("resync", sync_action)) {
+		if (!lv_is_on_pvs(seg_lv(seg, 0), target_pvs) &&
+		    !lv_is_on_pvs(seg_metalv(seg, 0), target_pvs))
+			return 1;
+		log_error("Unable to remove primary RAID image while array resyncing.");
+		return 0;
+	}
 
 	/* If anything other than "recover", rebuild or "idle" */
-        /* Targets reports for a while 'idle' state, before recover starts */
+	/* Targets reports for a while 'idle' state, before recover starts */
 	if (strcmp("recover", sync_action) &&
 	    strcmp("rebuild", sync_action) &&
 	    strcmp("idle", sync_action)) {


