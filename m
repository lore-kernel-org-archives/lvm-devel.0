From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Jun 2013 07:38:12 +0000 (UTC)
Subject: master - clean: remove unneeded assign
Message-ID: <20130617073812.44E2260FDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2636cae13991d6c9d51013c8702b13155577729a
Commit:        2636cae13991d6c9d51013c8702b13155577729a
Parent:        362d8ead64baa4ca520a8b39db99d223a7b54a2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 16 21:05:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 17 09:34:56 2013 +0200

clean: remove unneeded assign

Since init_unknown_segtype returns zalloced memory,
NULL assign is not needed.
---
 lib/metadata/segtype.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index 7218743..02dff4c 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -22,16 +22,15 @@ struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 {
 	struct segment_type *segtype;
 
-	dm_list_iterate_items(segtype, &cmd->segtypes) {
+	dm_list_iterate_items(segtype, &cmd->segtypes)
 		if (!strcmp(segtype->name, str))
 			return segtype;
-	}
 
 	if (!(segtype = init_unknown_segtype(cmd, str)))
 		return_NULL;
 
-	segtype->library = NULL;
 	dm_list_add(&cmd->segtypes, &segtype->list);
 	log_warn("WARNING: Unrecognised segment type %s", str);
+
 	return segtype;
 }


