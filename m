From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:33:17 -0500
Subject: master - tests: raise minsize of xfs
Message-ID: <201811162333.wAGNXHtI016142@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=97a95f9648ffe2882ad7fadcea3f0908c8947c7d
Commit:        97a95f9648ffe2882ad7fadcea3f0908c8947c7d
Parent:        fd8001a9fc7ea3a49c2b9fc3c3e20367e5dcf401
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 13 16:27:33 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

tests: raise minsize of xfs

mkfs.xfs now needs at least ~1600...
---
 test/shell/fsadm.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index fa9da35..8141da4 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -143,7 +143,7 @@ if check_missing ext3; then
 fi
 
 if check_missing xfs; then
-	mkfs.xfs -l internal,size=1000b -f "$dev_vg_lv"
+	mkfs.xfs -l internal,size=2000b -f "$dev_vg_lv"
 
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs


