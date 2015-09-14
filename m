From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Sep 2015 18:20:39 +0000 (UTC)
Subject: master - libdm: no validate for pool without messages
Message-ID: <20150914182039.DE8BD60CF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c356991fa83b15af261e8d7e33f5615397c07778
Commit:        c356991fa83b15af261e8d7e33f5615397c07778
Parent:        e42ee69988fc770314a355e6acd417e00e0c9623
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 14:59:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 20:18:54 2015 +0200

libdm: no validate for pool without messages

Avoid validation of free space in pool, when no messages are passed.

Patch a3c7e326c3e9950fe74e433c406d6e1b5a53bf25 add new check for
pool overload - but this check should not be made if there are
no messages and transaction_id is still within 'bounds' (bigger by 1).
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index db40deb..9e30786 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.108 - 
 =====================================
+  Do not check for full thin pool when activating without messages (1.02.107).
 
 Version 1.02.107 - 5th September 2015
 =====================================
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d40362d..7b7ca5b 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1633,7 +1633,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 		return 0;
 	}
 
-	if (!send)
+	if (!have_messages || !send)
 		return 1; /* transaction_id is matching */
 
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {


