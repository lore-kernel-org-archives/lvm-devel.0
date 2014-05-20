From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:59 +0000 (UTC)
Subject: master - tests: wait before down-convert
Message-ID: <20140520195359.7E15160C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f92c3a13eeba179872dacd4b632d8bb5188a0ba
Commit:        7f92c3a13eeba179872dacd4b632d8bb5188a0ba
Parent:        205be247689d7be38b4341401516a1881e09c6aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 19 14:30:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:29 2014 +0200

tests: wait before down-convert

---
 test/shell/lvconvert-mirror.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 1e9925a..8c0c72e 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -191,6 +191,10 @@ lvremove -ff $vg
 # "remove from original mirror (the original becomes linear)"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
+# FIXME: Extra wait here for mirror upconvert synchronization
+# otherwise we may fail her on parallel upconvert and downconvert
+# lvconvert-mirror-updown.sh tests this errornous case separately
+lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
 lvconvert $vg/$lv1
 


