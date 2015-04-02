From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:24 +0000 (UTC)
Subject: master - tests: drop check for awk
Message-ID: <20150402114124.EEDF56023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a16324b0d3ee2e3166ca0a9b5c87b5a68e756a68
Commit:        a16324b0d3ee2e3166ca0a9b5c87b5a68e756a68
Parent:        ee65528547aaec2076d7dc5bf61285732dbbb534
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 27 13:43:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

tests: drop check for awk

---
 test/lib/aux.sh |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b9f63b5..a14b7a3 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -324,9 +324,6 @@ prepare_scsi_debug_dev() {
 	test -z "$LOOP"
 	test -n "$DM_DEV_DIR"
 
-	# Skip test if awk isn't available (required for get_sd_devs_)
-	which awk || skip
-
 	# Skip test if scsi_debug module is unavailable or is already in use
 	modprobe --dry-run scsi_debug || skip
 	lsmod | not grep -q scsi_debug || skip


