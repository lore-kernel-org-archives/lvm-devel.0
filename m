From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:21:55 -0400
Subject: master - tests: system_id remove clustered vg test
Message-ID: <201806071521.w57FLtiR013173@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e966752b867c0fe379737b0bda1e850a19dabf00
Commit:        e966752b867c0fe379737b0bda1e850a19dabf00
Parent:        229582c97caee65799992b1e125243c3193892b9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 14:35:27 2018 -0500
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 7 16:17:04 2018 +0100

tests: system_id remove clustered vg test

---
 test/shell/system_id.sh |   24 ------------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 21c5bd0..ec7953d 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -275,30 +275,6 @@ grep $vg1 err
 grep "$SID1" err
 vgremove $vg1
 
-# vgchange -cy clears system_id, vgchange -cn sets system_id
-
-SID1=sidfoofile1
-echo "$SID1" > "$SIDFILE"
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-# create a vg
-vgcreate $vg1 "$dev1"
-# normal vgs sees the vg
-vgs -o+systemid >err
-grep $vg1 err
-grep "$SID1" err
-# after vgchange -cy there is no systemid
-vgchange --yes -cy $vg1
-vgs --config 'global { locking_type=0 }' -o+systemid $vg1 >err
-grep $vg1 err
-not grep "$SID1" err
-# after vgchange -cn there is a systemid
-vgchange --config 'global { locking_type=0 }' -cn $vg1
-vgs -o+systemid >err
-grep $vg1 err
-grep "$SID1" err
-vgremove $vg1
-
 # Test max system_id length (128) and invalid system_id characters.
 # The 128 length limit is imposed before invalid characters are omitted.
 


