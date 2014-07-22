From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:42:07 +0000 (UTC)
Subject: master - tests: use full option name
Message-ID: <20140722204207.C92FD605FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee11bb841612ec4dba173c31bf795a8560ca134e
Commit:        ee11bb841612ec4dba173c31bf795a8560ca134e
Parent:        b51f1b3df6c07f611ce364b4b662af7a2d1c9544
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 22 22:14:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:41:41 2014 +0200

tests: use full option name

Don't overuse shortcut support -
since poolmetadatasize was the only allowed option
it's been equivalent to poolmetadata
---
 test/shell/lvresize-thin-metadata.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index a034d07..9e2ae4d 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -26,14 +26,14 @@ for deactivate in true false; do
 
 	test $deactivate && lvchange -an $vg
 
-	lvresize --poolmetadata +2M $vg/pool
+	lvresize --poolmetadatasize +2M $vg/pool
 # Test it's been resized to 4M
 	check lv_field $vg/pool_tmeta size "4.00m"
 
-	lvresize --poolmetadata +256M $vg/pool
+	lvresize --poolmetadatasize +256M $vg/pool
 	check lv_field $vg/pool_tmeta size "260.00m"
 
-	lvresize --poolmetadata +3G $vg/pool
+	lvresize --poolmetadatasize +3G $vg/pool
 	check lv_field $vg/pool_tmeta size "3.25g"
 
 	vgchange -an $vg


