From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:45 +0000 (UTC)
Subject: master - cleanup: relocate error capture
Message-ID: <20151109092845.7780660661@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c380c316c51920db5b5721863cb1b55bfa9acf1
Commit:        0c380c316c51920db5b5721863cb1b55bfa9acf1
Parent:        67b4761bc3c53ee67a1fbe33f41757a6563db5cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 4 14:53:25 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:21:09 2015 +0100

cleanup: relocate error capture

Capture internal error before allocation anything.
---
 lib/metadata/lv_manip.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e23a8b9..c9cc6b5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3165,6 +3165,12 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	else
 		area_count = stripes;
 
+	if (!segtype_is_virtual(segtype) &&
+	    !(area_count + metadata_area_count)) {
+		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
+		return NULL;
+	}
+
 	size = sizeof(*ah);
 
 	/*
@@ -3203,11 +3209,6 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	if (segtype_is_virtual(segtype))
 		return ah;
 
-	if (!(area_count + metadata_area_count)) {
-		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
-		return NULL;
-	}
-
 	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
 		log_error("allocation pool creation failed");
 		return NULL;


