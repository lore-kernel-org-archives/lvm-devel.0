From: okozina <okozina@fedoraproject.org>
Date: Tue, 20 Oct 2015 10:19:27 +0000 (UTC)
Subject: master - polldaemon: fix missing mirror in-sync info with lvmpolld
Message-ID: <20151020101927.18B2960F6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=33465066c5eddaa6169814d645d543e5673bc2a6
Commit:        33465066c5eddaa6169814d645d543e5673bc2a6
Parent:        a5c4c4efbd18809320f49d7ed60c58883140259c
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Oct 19 16:56:45 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 20 12:18:55 2015 +0200

polldaemon: fix missing mirror in-sync info with lvmpolld

CONVERTING status flag is a tricky one. It's not set when converting
a non-mirror LV type to the mirror type, i.e.: linear -> two leg mirror.
Also the conversion itself is instant and doesn't require to be polled.
When mirror reaches sync state there's no final update on VG metadata
for lvmpolld to be made thereby report_progress in fact doesn't report
percentage of mirror being converted but percentage of mirror
being in sync. Perhaps we should reword the lvconvert output here.

On the other hand CONVERTING is set while we upconvert the mirror
from i.e. two leg mirror to four leg mirror. In such case the operation
is required to be polled so that lvmpolld can cleanup temporary
conversion log when the conversion is over.

Ignore CONVERTING lv_type for the moment and match LVs only by uuids
during 'mirror conversion'/'waiting for a sync to finish'.
---
 WHATS_NEW          |    1 +
 tools/polldaemon.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f973f11..763896e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Fix missing in-sync progress info while lvconvert used with lvmpolld.
   Add report/compact_output_cols to lvm.conf to define report cols to compact.
   Do not change logging in lvm2 library when it's already set.
   Check for enough space in thin-pool in command before creating new thin.
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index cee1983..ccfaa7d 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -412,7 +412,12 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 
 	if (lv && id->uuid && strcmp(id->uuid, (char *)&lv->lvid))
 		lv = NULL;
-	if (lv && parms->lv_type && !(lv->status & parms->lv_type))
+
+	/*
+	 * CONVERTING is set only during mirror upconversion but we may need to
+	 * read LV's progress info even when it's not converting (linear->mirror)
+	 */
+	if (lv && (parms->lv_type ^ CONVERTING) && !(lv->status & parms->lv_type))
 		lv = NULL;
 
 	if (!lv) {


