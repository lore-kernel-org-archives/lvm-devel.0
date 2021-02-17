From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:44 +0000 (GMT)
Subject: main - man: vdo drop resize restriction comment
Message-ID: <20210217105444.B1F313857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c0ce4daa2accbfeec2a09729f73ef7a5876c658
Commit:        9c0ce4daa2accbfeec2a09729f73ef7a5876c658
Parent:        19e137358008ce0a73c980d10cfdeaad7f9a5045
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 15 12:18:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:19 2021 +0100

man: vdo drop resize restriction comment

lvm2 supports resize of cached vdo pool volumes.
---
 man/lvmvdo.7_main | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 474d6dd73..520a28ecf 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -206,8 +206,6 @@ with the \fBactivation/vdo_pool_autoextend_percent\fP and
 
 Note: You cannot reduce the size of a VDOPoolLV.
 
-Note: You cannot change the size of a cached VDOPoolLV.
-
 .nf
 .B lvextend -L+AddingSize VG/VDOPoolLV
 .fi
@@ -265,9 +263,6 @@ VDODataLV (accepts also VDOPoolLV) caching provides a mechanism
 to accelerate reads and writes of already compressed and deduplicated
 data blocks together with VDO metadata.
 
-A cached VDO data LV cannot be currently resized. Also, the threshold
-based automatic resize will not work.
-
 .I Example
 .nf
 # lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vdopool


