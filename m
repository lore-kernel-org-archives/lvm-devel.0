From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:29 +0000 (UTC)
Subject: master - tests: add extra wait
Message-ID: <20140224201729.5257160EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80831438220f0ee8b88d2c8c25fab131bf619f5b
Commit:        80831438220f0ee8b88d2c8c25fab131bf619f5b
Parent:        dc839fb3610a344d6c392a09995e44e6dbfac545
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 10:56:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:36 2014 +0100

tests: add extra wait

Parallel upconvert & downconvert is now tested separately
in lvconvert-mirror-updown.sh
---
 test/shell/lvconvert-mirror.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 911e022..097e0d4 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -176,6 +176,10 @@ lvremove -ff $vg
 # "remove from original mirror (the original is still mirror)"
 lvcreate -aey -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
+# FIXME: Extra wait here for mirror upconvert synchronization
+# otherwise we may fail her on parallel upconvert and downconvert
+# lvconvert-mirror-updown.sh tests this errornous case separately
+lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
 lvconvert $vg/$lv1
 


