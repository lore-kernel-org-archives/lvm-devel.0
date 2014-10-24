From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:05 +0000 (UTC)
Subject: master - libdm: add DM_LIST_HEAD_INIT macro
Message-ID: <20141024144005.9698860E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=482e572e5de327ce3b8786215cf33e6d6223c543
Commit:        482e572e5de327ce3b8786215cf33e6d6223c543
Parent:        a98ea95c4da5afffbacd32c519734e7daef98ea9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 14:30:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

libdm: add DM_LIST_HEAD_INIT macro

Support to initialize dm_list struct members.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d60b35f..5ab34c1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Add DM_LIST_HEAD_INIT macro to libdevmapper.h
   Fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
 
 Version 1.02.90 - 1st September 2014
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 31574af..76c4eee 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1200,7 +1200,8 @@ struct dm_str_list {
  * Initialise a list before use.
  * The list head's next and previous pointers point back to itself.
  */
-#define DM_LIST_INIT(name)	struct dm_list name = { &(name), &(name) }
+#define DM_LIST_HEAD_INIT(name)	 { &(name), &(name) }
+#define DM_LIST_INIT(name)	struct dm_list name = DM_LIST_HEAD_INIT(name)
 void dm_list_init(struct dm_list *head);
 
 /*


