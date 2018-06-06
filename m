From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 17:37:13 -0400
Subject: master - tests: system_id remove clustered vg test
Message-ID: <201806062137.w56LbDKp023061@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55521be2cbe28b0580fafafff6151cf4b6a219ea
Commit:        55521be2cbe28b0580fafafff6151cf4b6a219ea
Parent:        802382e21ff600307f7c16f4651966d9a7c21252
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 14:35:27 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 14:35:27 2018 -0500

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
 


