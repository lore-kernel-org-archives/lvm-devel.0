From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:38 -0500
Subject: master - libdm: avoid checking status on activation
Message-ID: <201712072003.vB7K3cWw005597@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=297d5915c3c927cba3a63bc9d6d1747271d06641
Commit:        297d5915c3c927cba3a63bc9d6d1747271d06641
Parent:        4a4ea47f709287444f3b0d8e0581ce17e730ef4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 7 17:52:01 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 21:00:36 2017 +0100

libdm: avoid checking status on activation

Variable props.send_messages has 3 states and was not used properly
here.  Activation in this moment does not need to verify thin-pool status
as that has been already checked on preload.
So only if there are some real messages (value 2) call function
for sending them.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dfa5a97..d9503c2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.146 -
 ====================================
+  Activation tree of thin pool skips duplicated check of pool status.
   Remove code supporting replicator target.
   Do not ignore failure of _info_by_dev().
   Propagate delayed resume for pvmove subvolumes.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ef5da59..f463eab 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1920,7 +1920,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 	 * resume should continue further, just whole command
 	 * has to report failure.
 	 */
-	if (r && dnode->props.send_messages &&
+	if (r && (dnode->props.send_messages > 1) &&
 	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len, 1)))
 		stack;
 


