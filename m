From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:34:14 -0400
Subject: master - tests: drop unneeded ;
Message-ID: <201707101234.v6ACYE5R022916@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5214e62f095909da03fac49d2a9e4fa7dabf7244
Commit:        5214e62f095909da03fac49d2a9e4fa7dabf7244
Parent:        c3d8ee4da215444832a0b969945f332e84821b9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 12:52:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop unneeded ;

---
 test/shell/lvmlockd-hello-world.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmlockd-hello-world.sh b/test/shell/lvmlockd-hello-world.sh
index e0a1505..194b997 100644
--- a/test/shell/lvmlockd-hello-world.sh
+++ b/test/shell/lvmlockd-hello-world.sh
@@ -14,7 +14,7 @@ test_description='Hello world for vgcreate with lvmlockd and sanlock'
 
 . lib/inittest
 
-[ -z "$LVM_TEST_LVMLOCKD" ] && skip;
+[ -z "$LVM_TEST_LVMLOCKD" ] && skip
 
 aux prepare_pvs 1
 


