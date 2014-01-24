From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Jan 2014 11:30:39 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140124113039.5F08A60E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=432ff4bd720596bd3e56290c29646e8ba43575fb
Commit:        432ff4bd720596bd3e56290c29646e8ba43575fb
Parent:        5e4647ec99b1de0923a311004e86649b50f81c1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 24 10:49:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 24 12:30:28 2014 +0100

cleanup: indent

---
 lib/metadata/thin_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 92c4177..b26723b 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -86,9 +86,9 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 
 	dm_list_add(&pool_seg->thin_messages, &tmsg->list);
 
-	log_debug_metadata("Added %s message",
+	log_debug_metadata("Added %s message.",
 			   (type == DM_THIN_MESSAGE_CREATE_SNAP ||
-			   type == DM_THIN_MESSAGE_CREATE_THIN) ? "create" :
+			    type == DM_THIN_MESSAGE_CREATE_THIN) ? "create" :
 			   (type == DM_THIN_MESSAGE_DELETE) ? "delete" : "unknown");
 
 	return 1;


