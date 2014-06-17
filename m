From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:29 +0000 (UTC)
Subject: master - snapshot: check it's still snapshot
Message-ID: <20140617132429.670A46090E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=435c82f8f6312758e1d198d4cb0a2158b7a51bac
Commit:        435c82f8f6312758e1d198d4cb0a2158b7a51bac
Parent:        a20de8af208725ff2054209aa7ff7f41cc770db6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 13:38:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:36:07 2014 +0200

snapshot: check it's still snapshot

While polling for snapshot, detect first the snapshot still
exits.  It's valid to have multiple polling threads watching
for the same thing and just 1 can 'win' the finish part.
All others should nicely 'fail'.
---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 82ce360..731d4c8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -801,7 +801,8 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 {
 	percent_t percent = PERCENT_0;
 
-	if (!lv_snapshot_percent(lv, &percent)) {
+	if (!lv_is_merging_origin(lv) ||
+	    !lv_snapshot_percent(lv, &percent)) {
 		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
 	} else if (percent == PERCENT_INVALID) {


