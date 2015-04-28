From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Apr 2015 09:36:38 +0000 (UTC)
Subject: master - tests: drop debug test
Message-ID: <20150428093638.45DD361086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a378e5a6dd3e8a2d8ccb69bb9f0acdd1e279b1dc
Commit:        a378e5a6dd3e8a2d8ccb69bb9f0acdd1e279b1dc
Parent:        0c1bda9b53d1935a6eadea579061c323366c8e61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 27 17:44:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 28 11:23:16 2015 +0200

tests: drop debug test

Remove 'debug leftover' from test.
---
 test/shell/pvcreate-operation-md.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 2bfb937..810fc53 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -75,7 +75,6 @@ EOF
 	test "$DM_DEV_DIR" != "/dev" && cp -LR "${mddev}p1" "$DM_DEV_DIR"
 
 	pvcreate --metadatasize 128k "${pvdev}p1"
-	check sysfs "${pvdev}p1" alignment_offset 0
 
 	maj=$(($(stat -L --printf=0x%t "${mddev}p1")))
 	min=$(($(stat -L --printf=0x%T "${mddev}p1")))


