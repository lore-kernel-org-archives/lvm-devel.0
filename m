From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  2 Aug 2016 15:25:11 +0000 (UTC)
Subject: master - lvconvert: Treat --repair as an independent case.
Message-ID: <20160802152511.EC6FE60E7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6361bc4734f2227f049cb6ef0335f30468c2775d
Commit:        6361bc4734f2227f049cb6ef0335f30468c2775d
Parent:        804a397643a38b9c82d22eacaca2138f2af57bec
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 2 16:21:34 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 2 16:22:12 2016 +0100

lvconvert: Treat --repair as an independent case.

---
 tools/lvconvert.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 80760c6..6c57191 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -626,7 +626,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 	/* We should have caught all these cases already. */
 	if (lp->merge + lp->splitsnapshot + lp->splitcache + lp->split + lp->uncache +
-	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot + lp->replace > 1) {
+	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot + lp->replace + lp->repair > 1) {
 		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
 		return 0;
 	}
@@ -643,7 +643,8 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	 *   lp->keep_mimages
 	 *   lp->snapshot
 	 *   lp->replace
-	 *   --type mirror|raid  lp->repair lp->mirrorlog lp->corelog
+	 *   lp->repair
+	 *   --type mirror|raid  lp->mirrorlog lp->corelog
 	 *   --type raid0|striped
 	 */
 	if (lp->merge) {	/* Snapshot or mirror merge */
@@ -722,8 +723,10 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 								    tmp_str)))
 				return_0;
 		}
-	} else if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
-		   lp->repair || lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
+	} else if (lp->repair)
+		;
+	else if (_mirror_or_raid_type_requested(cmd, lp->type_str) ||
+		   lp->mirrorlog || lp->corelog) { /* Mirrors (and some RAID functions) */
 		if (arg_is_set(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with snapshots or pools.");
 			return 0;


