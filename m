From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Sep 2019 13:55:58 -0400
Subject: master - tests: unnecessary braces causes test failures
Message-ID: <201909121755.x8CHtwU3029044@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39a0de68bdbd26bf64e2cc92731c9095c5d36e17
Commit:        39a0de68bdbd26bf64e2cc92731c9095c5d36e17
Parent:        585db872749a08dd42139cbf4234cbcd50a19683
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 12 12:55:00 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 12:55:00 2019 -0500

tests: unnecessary braces causes test failures

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b7207eb..9c9e1fd 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1190,7 +1190,7 @@ devices/dir = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
 devices/global_filter = [ "a|$DM_DEV_DIR/mapper/${PREFIX}.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection = 0
-devices/scan = [ "$DM_DEV_DIR" ]
+devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1
 devices/write_cache_state = 0
 global/abort_on_internal_errors = 1


