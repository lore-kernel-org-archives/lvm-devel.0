From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 30 May 2017 12:44:52 -0400
Subject: master - tests: also check new flag with segtype
Message-ID: <201705301644.v4UGiqCB014296@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c84c5c421806d5ee3fbe885862839a27df7b36a
Commit:        7c84c5c421806d5ee3fbe885862839a27df7b36a
Parent:        fb86bddda2e2944699d9c0705a16642ed1dc99b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 30 16:10:22 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue May 30 18:43:56 2017 +0200

tests: also check new flag with segtype

Make sure new unknown flag is having same behavior as old unknown segtype.
---
 test/shell/unknown-segment.sh |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index 27cea88..20fc920 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -18,9 +18,10 @@ aux prepare_vg 4
 
 lvcreate -an -Zn -l 1 -n $lv1 $vg
 lvcreate -an -Zn -l 2 --type mirror -m 1 -n $lv2 $vg
+lvcreate -an -Zn --type zero -l 1 -n $lv3 $vg
 
 vgcfgbackup -f bak0 $vg
-sed -e 's,striped,unstriped,;s,mirror,unmirror,' -i.orig bak0
+sed -e 's,striped,unstriped,;s,mirror,unmirror,;s,zero,zero+NEWFLAG,' -i.orig bak0
 vgcfgrestore -f bak0 $vg
 
 # we have on-disk metadata with unknown segments now
@@ -28,11 +29,13 @@ not lvchange -aey $vg/$lv1 # check that activation is refused
 
 # try once more to catch invalid memory access with valgrind
 # when clvmd flushes cmd mem pool
-not lvchange -aey $vg/$lv1 # check that activation is refused
+not lvchange -aey $vg/$lv2 # check that activation is refused
+
+not lvchange -aey $vg/$lv3 # check that activation is refused
 
 vgcfgbackup -f bak1 $vg
 cat bak1
-sed -e 's,unstriped,striped,;s,unmirror,mirror,' -i.orig bak1
+sed -e 's,unstriped,striped,;s,unmirror,mirror,;s,zero+NEWFLAG,zero,' -i.orig bak1
 vgcfgrestore -f bak1 $vg
 vgcfgbackup -f bak2 $vg
 


