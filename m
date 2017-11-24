From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:10:54 -0500
Subject: master - libdm: preload propagates delayed resume
Message-ID: <201711241510.vAOFAsMf000361@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa68b898ff9c51dcbd87c6be34632e33f0299a18
Commit:        aa68b898ff9c51dcbd87c6be34632e33f0299a18
Parent:        b5be7420d947b9bfe52da73078955ed241765875
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 13:57:22 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:05:21 2017 +0100

libdm: preload propagates delayed resume

Propagate delayed resume at least for preload case in a simple way.
Currently  PVMOVE depends on internal logic where 'mirror' with
corelog is 'possible' PVMOVE. In such case resume of 'created'
node is 'delayed'.

This is mostly an ugly internal hack - but for the moment being when we
add propagation for preload - it does work reasonable.

TODO: provide standard API and avoid this internal 'guessing'.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b7f71ca..9cec953 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.146 -
 ====================================
+  Propagate delayed resume for pvmove subvolumes.
   Suppress integrity encryption keys in 'table' output unless --showkeys supplied.
 
 Version 1.02.145 - 3rd November 2017
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index b0a48f3..547904f 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2962,6 +2962,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 
 	/* Preload children first */
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+		/* Propagate delay of resume from parent node */
+		if (dnode->props.delay_resume_if_new)
+			child->props.delay_resume_if_new = 1;
+
 		/* Skip existing non-device-mapper devices */
 		if (!child->info.exists && child->info.major)
 			continue;


