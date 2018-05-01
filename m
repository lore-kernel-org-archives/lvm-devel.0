From: David Teigland <teigland@sourceware.org>
Date: Tue, 1 May 2018 14:30:31 -0400
Subject: master - tests: remove use of lvm1 metadatatype
Message-ID: <201805011830.w41IUVIn017747@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39f05855c0f985a20951cd3394d97c166dd9af5d
Commit:        39f05855c0f985a20951cd3394d97c166dd9af5d
Parent:        d709d8445f206b67cfc06266ce7553f9cb6f3df5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 1 13:28:10 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 1 13:29:57 2018 -0500

tests: remove use of lvm1 metadatatype

---
 test/shell/vgcreate-usage.sh |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index 16117c3..ee7dd99 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -68,10 +68,6 @@ vgcreate $vg "$dev1" "$dev2"
 not vgcreate $vg "$dev1" "$dev2"
 vgremove -ff $vg
 
-#COMM 'vgcreate rejects MaxLogicalVolumes > 255'
-not vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg "$dev1" "$dev2" 2>err
-grep "Number of volumes may not exceed 255" err
-
 #COMM "vgcreate fails when the only pv has --metadatacopies 0"
 not vgcreate $vg "$dev3"
 


