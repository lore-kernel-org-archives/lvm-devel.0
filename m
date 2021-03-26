From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 12:18:04 +0000 (GMT)
Subject: main - tests: try to observe some unusual problem
Message-ID: <20210326121804.7803B3858024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6db533c4393e1e8ca02e957c529afaf67fa7e20b
Commit:        6db533c4393e1e8ca02e957c529afaf67fa7e20b
Parent:        3ed79d8dfe8b75830d8fd6925d7cef5ef1ebd8f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 11:36:22 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 11:36:22 2021 +0100

tests: try to observe some unusual problem

Lets see, why it's very occasionaly able to active LV.
---
 test/shell/duplicate-vgnames.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/duplicate-vgnames.sh b/test/shell/duplicate-vgnames.sh
index 0f98f9c37..0bbc08937 100644
--- a/test/shell/duplicate-vgnames.sh
+++ b/test/shell/duplicate-vgnames.sh
@@ -399,7 +399,7 @@ grep $UUID2 out | grep active
 grep $UUID3 out | not grep active
 vgchange -an
 
-not vgchange -ay $vg1
+not vgchange -ay -vvvv $vg1
 lvs --foreign -o vguuid,active |tee out
 grep $UUID1 out | not grep active
 grep $UUID2 out | not grep active


