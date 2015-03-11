From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 20:17:43 +0000 (UTC)
Subject: master - tests: drop unneeded comment
Message-ID: <20150311201743.E088460242@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbe4f7e4c58a660694e5fdee0a981d67000a09de
Commit:        bbe4f7e4c58a660694e5fdee0a981d67000a09de
Parent:        243a135fe9091a3d306ee09b397779e503bb6adf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 15:42:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 21:17:23 2015 +0100

tests: drop unneeded comment

---
 test/shell/lvconvert-mirror-updown.sh |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index 67862ac..ddd34c7 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -28,9 +28,7 @@ lvconvert -m+1 -b $vg/$lv1 "$dev3"
 #lvconvert $vg/$lv1
 
 lvs -a $vg
-#
-# It fails so use 'should' and -vvvv for now
-#
+
 lvconvert -m-1 $vg/$lv1 "$dev2"
 
 vgremove -f $vg


