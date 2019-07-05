From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:27 -0400
Subject: stable-2.02 - tests: raise minsize of xfs
Message-ID: <201907052326.x65NQRNH009740@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1cc409ae6808cd00b908756b53a4d58338aa5f7
Commit:        e1cc409ae6808cd00b908756b53a4d58338aa5f7
Parent:        721a172edf1a997b2c849f046b1ac88d6318f6d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 13 16:27:33 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

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


