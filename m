From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Aug 2013 21:18:39 +0000 (UTC)
Subject: master - test: can convert pool to external origin
Message-ID: <20130809211839.E5B2460F95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1dc585fa655a0d6da278fba4b9e249b4a7193ce
Commit:        a1dc585fa655a0d6da278fba4b9e249b4a7193ce
Parent:        e583ff3d2c9996f1a7e684fe9da18745114dedfe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 9 23:17:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 23:17:15 2013 +0200

test: can convert pool to external origin

Test for http://bugzilla.redhat.com/show_bug.cgi?id=983743
---
 test/shell/lvconvert-thin-external.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 9f53fcb..a700b37 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -48,6 +48,10 @@ fi
 #exit 0
 
 lvcreate -l10 -T $vg/pool
+# Can't convert pool to external origin
+lvcreate -l10 -T $vg/pool1
+not lvconvert -T --thinpool $vg/pool1 $vg/pool --originname origin
+lvremove -f $vg/pool1
 
 # create plain LV (will be used for external origin)
 lvcreate -L8M -n $lv1 $vg


