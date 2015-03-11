From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 10:02:04 +0000 (UTC)
Subject: master - tests: extend race
Message-ID: <20150311100204.6FCD060D6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a2b9f045fffd4e9d9450477b946af31dde5848f
Commit:        8a2b9f045fffd4e9d9450477b946af31dde5848f
Parent:        ed2dcb796ffc0cac6cee38b5198816e77a3a3bfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 19 17:08:33 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 11:02:35 2015 +0100

tests: extend race

Mark test as skipped, if the test could not be made.
---
 test/shell/lvextend-snapshot-dmeventd.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 448df96..c944322 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -47,6 +47,10 @@ lvchange --monitor y $vg/snap
 
 write_ 1000 1700
 pre=$(percent_)
+# Normally the usage should be ~66% here, however on slower systems
+# dmeventd could be actually 'fast' enough to have COW already resized now
+# so mark test skipped if we are bellow 50% by now
+test $pre -gt 50 || skip
 wait_for_change_ $pre
 test $pre -gt $(percent_)
 
@@ -56,6 +60,8 @@ test $pre -gt $(percent_)
 
 write_ 2700 2000
 pre=$(percent_)
+# Mark test as skipped if already resized...
+test $pre -gt 70 || skip
 wait_for_change_ $pre
 test $pre -gt $(percent_)
 


