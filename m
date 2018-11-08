From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Nov 2018 06:23:42 -0500
Subject: master - devicemapper: retry remove even for subLVs
Message-ID: <201811081123.wA8BNgqr013957@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cee8f1b063dcf5d809e14de38ba489ce5b8f562
Commit:        6cee8f1b063dcf5d809e14de38ba489ce5b8f562
Parent:        c1703845c3d82e381c545b8ad8bde68bafc2fbcf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 8 12:12:58 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 8 12:20:57 2018 +0100

devicemapper: retry remove even for subLVs

With older systems and udevs we don't have control over scanning of lvm2
internal devices - so far we set retry-removal only for top-level LVs,
but in occasional cases udev can be 'fast enough' to open device for
scanning and prevent removal of such device from DM table.

So to combat this case - try to pass 'retry' flag also for removal of
internal device so see how many races can go away with this simple
patch.

Note: patch is applied only to internal version of libdm so the external
API remains working in the old way for now.
---
 device_mapper/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 89a0a48..06f10ae 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -1804,7 +1804,7 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags,
-				      (level == 0) ? child->dtree->retry_remove : 0)) {
+				      child->dtree->retry_remove)) {
 			log_error("Unable to deactivate %s (" FMTu32 ":"
 				  FMTu32 ").", name, info.major, info.minor);
 			r = 0;


