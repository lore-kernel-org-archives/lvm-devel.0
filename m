From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 16 Oct 2013 08:56:15 +0000 (UTC)
Subject: master - tests: add wait
Message-ID: <20131016085615.DDEEA60BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ab5f29a9cf94ef41e54e47f7f00898d44a700e3
Commit:        7ab5f29a9cf94ef41e54e47f7f00898d44a700e3
Parent:        1b7631101b2ac34d25cd5d3140001e86371997f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 20:23:23 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 16 10:53:03 2013 +0200

tests: add wait

We need to wait till kill really kills sleep
---
 test/shell/snapshot-usage.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index d7a602b..3d4d308 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -20,6 +20,7 @@ fill() {
 cleanup_tail()
 {
 	test -z "$SLEEP_PID" || kill $SLEEP_PID
+	wait
 	aux teardown
 }
 
@@ -57,6 +58,8 @@ not lvremove -f $vg1/$lv1
 
 kill $SLEEP_PID
 SLEEP_PID=
+# Wait for killed task, so there is no device holder
+wait
 
 lvremove -f $vg1/$lv1
 not dmsetup info $vg1-$lv1 >/dev/null || \


