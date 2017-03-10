From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 09:42:46 -0500
Subject: master - libdm: dm_stats_start_filemapd() mode can never be < 0
Message-ID: <201703101442.v2AEgkeU022767@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93644be44b4067c6ebc1d450589ca510129b3b60
Commit:        93644be44b4067c6ebc1d450589ca510129b3b60
Parent:        bc3bec6c5486105f50fe94e66c1a16dc0fdfe332
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 14:42:23 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 14:42:23 2017 +0000

libdm: dm_stats_start_filemapd() mode can never be < 0

---
 libdm/libdm-stats.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index cff23d8..61c052f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4948,8 +4948,7 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
 		return 0;
 	}
 
-	if (mode < DM_FILEMAPD_FOLLOW_INODE
-	    || mode > DM_FILEMAPD_FOLLOW_PATH) {
+	if (mode > DM_FILEMAPD_FOLLOW_PATH) {
 		log_error("Invalid dmfilemapd mode argument: "
 			  "Must be DM_FILEMAPD_FOLLOW_INODE or "
 			  "DM_FILEMAPD_FOLLOW_PATH");


