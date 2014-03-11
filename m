From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:18 +0000 (UTC)
Subject: master - thin: do not check of empty pool with messages
Message-ID: <20140311233418.E2A6F60EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d64e91efde5335eeae6f2e0fcdf4992b054644a
Commit:        4d64e91efde5335eeae6f2e0fcdf4992b054644a
Parent:        1850a6e454ebbb54aae80a0ad4d5482ecdffcd28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 11 22:54:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:15:22 2014 +0100

thin: do not check of empty pool with messages

The empty pool is also the pool which has yet queued list of messages
and transaction_id == 1.

Problem is exposed when pool is created inactive.

lvcreate -L10 -T vg/pool -an
lvcreate -V10 -T vg/pool
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0fd0657..7814826 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Do not try to check empty pool with scheduled messages.
   Fix return value in pool_has_message() when quering for any message.
   Cleanup all client resources on clvmd exit.
   Use dm_zalloc to clear members of clvmd client struct.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6b5f8c2..006588c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1790,7 +1790,9 @@ static int _thin_pool_register_callback(struct dev_manager *dm,
 	struct thin_cb_data *data;
 
 	/* Skip metadata testing for unused pool. */
-	if (!first_seg(lv)->transaction_id)
+	if (!first_seg(lv)->transaction_id ||
+	    ((first_seg(lv)->transaction_id == 1) &&
+	     pool_has_message(first_seg(lv), NULL, 0)))
 		return 1;
 
 	if (!(data = dm_pool_alloc(dm->mem, sizeof(*data)))) {


