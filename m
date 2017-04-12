From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 17:06:45 -0400
Subject: master - tests: use egrep to check for message
Message-ID: <201704122106.v3CL6jcb024346@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3e8354479f2b6c3d35fdc992d4114b244326833
Commit:        a3e8354479f2b6c3d35fdc992d4114b244326833
Parent:        59d54d70e73f2ba60a0714a04af3699c23503761
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 12 22:52:56 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 23:05:50 2017 +0200

tests: use egrep to check for message

Seems we may get different '' around option on different nixes.
---
 test/shell/vgextend-restoremissing.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 7f8fee0..d94eb5c 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -24,7 +24,7 @@ invalid vgextend
 # --metadatacopies => use --pvmetadatacopies
 invalid vgextend --metadatacopies 3 $vg "$dev1" 2>&1 | tee out
 #grep -- "use --pvmetadatacopies" out
-grep -- "unrecognized option '--metadatacopies'" out
+egrep -- "unrecognized option.*--metadatacopies" out
 
 # VG name should exist
 fail vgextend --restoremissing $vg-invalid "$dev1"


