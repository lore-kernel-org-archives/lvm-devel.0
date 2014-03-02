From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Mar 2014 20:55:54 +0000 (UTC)
Subject: master - tests: use longer sleep
Message-ID: <20140302205554.9BE8F611B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2af5855c5b7e6360d246b802dadafbe79a6d5e4
Commit:        a2af5855c5b7e6360d246b802dadafbe79a6d5e4
Parent:        fade191aed03a9ec5027e9a61d8f39439bc01239
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 19:08:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 2 21:27:25 2014 +0100

tests: use longer sleep

Eplore why 30sec is not enough for hydra and try higher value.
---
 test/shell/snapshot-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index bd0723d..991c18a 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -74,7 +74,7 @@ lvs -a -o+lv_active $vg1
 
 trap 'cleanup_tail' EXIT
 # Keep device busy (but not mounted) for a while
-sleep 30 < "$DM_DEV_DIR/$vg1/$lv1" &
+sleep 120 < "$DM_DEV_DIR/$vg1/$lv1" &
 SLEEP_PID=$!
 
 # give some short time to lock file above


