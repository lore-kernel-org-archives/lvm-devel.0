From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:38:47 -0400
Subject: master - tests: using prepare_vg
Message-ID: <201707101238.v6ACclKF023859@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d23a475c98fae1a24111a0b4667bdaf5166ccde2
Commit:        d23a475c98fae1a24111a0b4667bdaf5166ccde2
Parent:        dafeb0274acae432054faf729510133780db9439
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 9 15:55:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: using prepare_vg

---
 test/shell/lvmetad-dump.sh |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 3260b73..8c9e74f 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -16,12 +16,11 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_pvs 2
-vgcreate $vg1 "$dev1" "$dev2"
-lvcreate -n bar -l 1 $vg1
+aux prepare_vg 2
+lvcreate -n bar -l 1 $vg
 
 aux lvmetad_dump | tee lvmetad.txt
 
-grep $vg1 lvmetad.txt
+grep $vg lvmetad.txt
 
-vgremove -ff $vg1
+vgremove -ff $vg


