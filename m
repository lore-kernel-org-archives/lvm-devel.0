From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 15:14:02 -0400
Subject: master - tests: aux.sh fix pattern
Message-ID: <201706301914.v5UJE2Nl030894@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=006a9eaada2744ca39b05aed7b7bf152524580be
Commit:        006a9eaada2744ca39b05aed7b7bf152524580be
Parent:        2ceb5a0abbbdc3753cfcaff76251d6477a9ea088
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 21:09:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 21:13:07 2017 +0200

tests: aux.sh fix pattern

Commit 72a58ce4b0f68f6e45ae30606fe5af21caa42b43 fixed 'translation' of
pattern by bash by using "" - so we need to drop '\' here to get
wanted behavior.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ed969e2..2eeb67f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1542,7 +1542,7 @@ wait_pvmove_lv_ready() {
 		while : ; do
 			test "$retries" -le 0 && die "Waiting for lvmpolld timed out"
 			test -n "$lvid" || {
-				lvid=$(get lv_field "${1//-/\/}" vg_uuid,lv_uuid -a 2>/dev/null)
+				lvid=$(get lv_field "${1//-//}" vg_uuid,lv_uuid -a 2>/dev/null)
 				lvid=${lvid//\ /}
 				lvid=${lvid//-/}
 			}


