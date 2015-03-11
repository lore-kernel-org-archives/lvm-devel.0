From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 10:02:02 +0000 (UTC)
Subject: master - tests: drop old workaround
Message-ID: <20150311100202.4FA4160D6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed2dcb796ffc0cac6cee38b5198816e77a3a3bfd
Commit:        ed2dcb796ffc0cac6cee38b5198816e77a3a3bfd
Parent:        a042678a83fd996bec20cb7e42c7b1df206b7671
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 09:54:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 11:02:35 2015 +0100

tests: drop old workaround

Should be usable now without this 'should'.
---
 test/shell/lvconvert-mirror-updown.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index 18618fd..67862ac 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -31,6 +31,6 @@ lvs -a $vg
 #
 # It fails so use 'should' and -vvvv for now
 #
-should lvconvert -vvvv -m-1 $vg/$lv1 "$dev2"
+lvconvert -m-1 $vg/$lv1 "$dev2"
 
 vgremove -f $vg


