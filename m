From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:16 +0000 (UTC)
Subject: master - thin: fix pool_has_message return for NULL params
Message-ID: <20140311233416.CE2AA60EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1850a6e454ebbb54aae80a0ad4d5482ecdffcd28
Commit:        1850a6e454ebbb54aae80a0ad4d5482ecdffcd28
Parent:        7574b3bc80c8b2db5f4a9da9e7de00c0a3239e26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 11 22:50:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:13:21 2014 +0100

thin: fix pool_has_message return for NULL params

When pool_has_message() is queried with NULL lv and 0 device_id
it should just return 'true' when there is any message queued.
So it needs to return negative value dm_list_empty().

Since there is no user for this code path in code currently,
this bug has not been triggered.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7d6f4d6..0fd0657 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix return value in pool_has_message() when quering for any message.
   Cleanup all client resources on clvmd exit.
   Use dm_zalloc to clear members of clvmd client struct.
   Use BLKID_CFLAGS when compiling with blkid support.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 2e49019..78231a2 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -160,7 +160,7 @@ int pool_has_message(const struct lv_segment *seg,
 	}
 
 	if (!lv && !device_id)
-		return dm_list_empty(&seg->thin_messages);
+		return !dm_list_empty(&seg->thin_messages);
 
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		switch (tmsg->type) {


