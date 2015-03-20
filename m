From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Mar 2015 10:11:44 +0000 (UTC)
Subject: master - tests: revert should removal in mirror test
Message-ID: <20150320101144.93A0360B44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=361e2d8df726e8428ed917939dab54643761b9e4
Commit:        361e2d8df726e8428ed917939dab54643761b9e4
Parent:        21343ffbfed94f41da11fac4dd056af58f4341a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 20 11:08:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 20 11:08:44 2015 +0100

tests: revert should removal in mirror test

Since cluster test was actually not been working,
removal of should has been premature.
So restore 'should' back - bug in mirror code is still there.
---
 test/shell/lvconvert-mirror-updown.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index ddd34c7..4d401fb 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -29,6 +29,9 @@ lvconvert -m+1 -b $vg/$lv1 "$dev3"
 
 lvs -a $vg
 
-lvconvert -m-1 $vg/$lv1 "$dev2"
+#
+# It fails so use 'should' and -vvvv for now
+#
+should lvconvert -vvvv -m-1 $vg/$lv1 "$dev2"
 
 vgremove -f $vg


