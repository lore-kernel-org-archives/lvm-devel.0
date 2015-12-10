From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Dec 2015 20:07:10 +0000 (UTC)
Subject: master - tests: fix logging
Message-ID: <20151210200710.DF23D61115@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0688dbbc5303ee99709f202a023e7b96a515f6aa
Commit:        0688dbbc5303ee99709f202a023e7b96a515f6aa
Parent:        cd8e95d9337207a8f87a6f68dc9b1db7e3828bbf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 10 20:47:30 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 10 21:01:24 2015 +0100

tests: fix logging

Actually  file redirection must be before stderr redir.
---
 test/shell/mdata-strings.sh     |    2 +-
 test/shell/thin-resize-match.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index fda09ec..d20234b 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -37,7 +37,7 @@ dm_table | grep -F "$pv_ugly"
 created="$dev1"
 # when used with real udev without fallback, it will fail here
 pvcreate "$dev1" || created="$dev2"
-pvdisplay 2>&1 | tee >err
+pvdisplay 2>&1 | tee err
 should grep -F "$pv_ugly" err
 should check pv_field "$dev1" pv_name "$dev1"
 vgcreate $vg "$created"
diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index d5481e2..4c6332d 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -34,7 +34,7 @@ check lv_field $vg/$lv1 size "2.00m"
 # prepare 2097152  file content
 seq 0 315465 > 2M
 md5sum 2M | cut -f 1 -d ' ' | tee MD5
-dd if=2M of="$DM_DEV_DIR/mapper/$vg-$lv1" bs=512K conv=fdatasync 2>&1 >log &
+dd if=2M of="$DM_DEV_DIR/mapper/$vg-$lv1" bs=512K conv=fdatasync >log 2>&1 &
 #dd if=2M of="$DM_DEV_DIR/mapper/$vg-$lv1" bs=2M oflag=direct &
 
 # give it some time to fill thin-volume


