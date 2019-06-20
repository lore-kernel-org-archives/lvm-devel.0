From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jun 2019 05:22:45 -0400
Subject: stable-2.02 - tests: update resize value
Message-ID: <201906200922.x5K9Mj9H009052@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b61c89b52b524b59a515123a9d659066cc4e183e
Commit:        b61c89b52b524b59a515123a9d659066cc4e183e
Parent:        78c937552a60e8e61cb9f1aca22095f28a39c174
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 17 16:14:59 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 10:55:55 2019 +0200

tests: update resize value

Since we now properly extend also _pmspare - there was not enough free
space to add 8extents to both volumes.
---
 test/shell/relative-sign-options.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 82a5ed2..dbf1644 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -77,7 +77,7 @@ lvresize --poolmetadatasize 64 $vg/$lv7
 lvresize --poolmetadatasize +8 $vg/$lv7
 not lvresize -y --poolmetadatasize -8 $vg/$lv7
 
-lvextend --poolmetadatasize +8 $vg/$lv7
+lvextend --poolmetadatasize +4 $vg/$lv7
 not lvextend -y --poolmetadatasize -8 $vg/$lv7
 fi
 


