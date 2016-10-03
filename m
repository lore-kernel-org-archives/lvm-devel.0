From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:18 +0000 (UTC)
Subject: master - tests: proper wait usage
Message-ID: <20161003155118.3674160198@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e33781d95f2fe7d412b97eb48cb8dddd1c07c61
Commit:        9e33781d95f2fe7d412b97eb48cb8dddd1c07c61
Parent:        43662fa081ccced622711aecfa21ef8d158a3dc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 29 13:18:18 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:49:56 2016 +0200

tests: proper wait usage

Fix missing wait so we have paired waiting.
Also 'wait' for precise PID to get 'exit' code.

Test for 'error' replacing only with newer snapshot targets.
The old one will wait for resume.

Note: 'wait -n' is not always available so can't be used..
---
 test/shell/snapshot-remove-dmsetup.sh |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 609df05..05bf720 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -42,6 +42,7 @@ dmsetup suspend $vg-$lv1
 
 # now this should pass without blocking
 dmsetup suspend --noflush --nolockfs $vg1-snap &
+DMPID=$!
 #dmsetup suspend $vg1-snap &
 
 sleep .5
@@ -55,20 +56,28 @@ dmsetup resume $vg-$lv1
 # otherwise --noudevsync would be needed
 dmsetup resume $vg1-snap
 
+# Expecting success from 'dmsetup'
+wait $DMPID
+
 
 # Try how force removal works
 dmsetup suspend $vg-$lv1
 # needs to fail as device is still open
 not dmsetup remove --force $vg1-snap &
+DMPID=$!
 
+# on older snapshot target 'remove' will wait till $lv1 is resumed
+if aux target_at_least dm-snapshot 1 6 0 ; then
 sleep .5
 
 dmsetup table $vg1-snap | tee out
 should grep -i error out
+fi
 
 dmsetup resume $vg-$lv1
 
-wait
+# Expecting success from 'not dmsetup'
+wait $DMPID
 
 # check it really is now 'error' target
 dmsetup table $vg1-snap | tee out


