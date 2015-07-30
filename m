From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jul 2015 14:14:25 +0000 (UTC)
Subject: master - cleanup: toolcontext: move report_list_item_separator into its group
Message-ID: <20150730141425.E277860DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9c67a9b21583e6665ba7c13a3fa2d0151082f5b
Commit:        d9c67a9b21583e6665ba7c13a3fa2d0151082f5b
Parent:        e6834b3237e2d523430a8b8a3ff24b0b27f7cb2f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 30 16:14:10 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 30 16:14:10 2015 +0200

cleanup: toolcontext: move report_list_item_separator into its group

---
 lib/commands/toolcontext.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index d2fd8a2..ec2242d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -165,7 +165,6 @@ struct cmd_context {
 	 * Host tags.
 	 */
 	struct dm_list tags;			/* list of defined tags */
-	const char *report_list_item_separator;
 	int hosttags;
 
 	/*
@@ -186,6 +185,7 @@ struct cmd_context {
 	/*
 	 * Others - unsorted.
 	 */
+	const char *report_list_item_separator;
 	const char *time_format;
 	unsigned rand_seed;
 };


