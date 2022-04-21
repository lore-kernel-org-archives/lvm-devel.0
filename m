From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Apr 2022 16:32:50 +0000 (GMT)
Subject: main - tests: devicesfile-edit.sh fix loop file name
Message-ID: <20220421163250.1950E383941A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c50590b22b37055e93b571fb26d1854f73ae2fd
Commit:        5c50590b22b37055e93b571fb26d1854f73ae2fd
Parent:        bee575d678399a45db09ec8fcba79eae3890ec54
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 11:31:06 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 11:31:06 2022 -0500

tests: devicesfile-edit.sh fix loop file name

don't remove dash from loop file name
---
 test/shell/devicesfile-edit.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/devicesfile-edit.sh b/test/shell/devicesfile-edit.sh
index 2a046e213..a71ca0c43 100644
--- a/test/shell/devicesfile-edit.sh
+++ b/test/shell/devicesfile-edit.sh
@@ -141,8 +141,8 @@ rm $DF
 lvmdevices --adddev "$LOOP1"
 lvmdevices --adddev "$LOOP2"
 vgcreate $vg "$LOOP1" "$LOOP2"
-IDNAME1=`pvs "$LOOP1" --noheading -o deviceid | tr -d - | awk '{print $1}'`
-IDNAME2=`pvs "$LOOP2" --noheading -o deviceid | tr -d - | awk '{print $1}'`
+IDNAME1=`pvs "$LOOP1" --noheading -o deviceid | awk '{print $1}'`
+IDNAME2=`pvs "$LOOP2" --noheading -o deviceid | awk '{print $1}'`
 lvmdevices --deldev "$IDNAME2" --deviceidtype loop_file
 not grep "$IDNAME2" $DF
 not grep "$LOOP2" $DF

