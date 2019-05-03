From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 3 May 2019 07:18:30 -0400
Subject: master - tests: update resize value
Message-ID: <201905031118.x43BIUZM028359@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c56e31134baa5e7ddf8881e8a23d5ac5f2459a6
Commit:        8c56e31134baa5e7ddf8881e8a23d5ac5f2459a6
Parent:        d60d59a5f30e7f324eed9605a8c1c925fbce63e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 17 16:14:59 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 13:17:22 2019 +0200

tests: update resize value

Since we now properly extend also _pmspare - there was not enough free
space to add 8extents to both volumes.
---
 test/shell/relative-sign-options.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 8333998..ac6fe53 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -73,7 +73,7 @@ lvresize --poolmetadatasize 64 $vg/$lv7
 lvresize --poolmetadatasize +8 $vg/$lv7
 not lvresize -y --poolmetadatasize -8 $vg/$lv7
 
-lvextend --poolmetadatasize +8 $vg/$lv7
+lvextend --poolmetadatasize +4 $vg/$lv7
 not lvextend -y --poolmetadatasize -8 $vg/$lv7
 fi
 


