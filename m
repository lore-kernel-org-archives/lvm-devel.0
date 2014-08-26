From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:36 +0000 (UTC)
Subject: master - cleanup: use unsigned 1bit elements
Message-ID: <20140826121736.CA41C6115B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b5afac9b433dd26f4461d4f59401bbb299219ec
Commit:        3b5afac9b433dd26f4461d4f59401bbb299219ec
Parent:        e5356eeba10858c2bb0f57891c262f77707b19bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 21 15:37:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:13:06 2014 +0200

cleanup: use unsigned 1bit elements

Avoid using signed 'int' type for 1 bit size.
---
 lib/config/config.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index 7b1d5b6..d095519 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -139,10 +139,10 @@ struct config_def_tree_spec {
 	struct cmd_context *cmd;	/* command context (for run-time defaults */
 	cfg_def_tree_t type;		/* tree type */
 	uint16_t version;		/* tree at this LVM2 version */
-	int ignoreadvanced:1;		/* do not include advanced configs */
-	int ignoreunsupported:1;	/* do not include unsupported configs */
-	int withcomments:1;		/* include comments */
-	int withversions:1;		/* include versions */
+	unsigned ignoreadvanced:1;		/* do not include advanced configs */
+	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
+	unsigned withcomments:1;		/* include comments */
+	unsigned withversions:1;		/* include versions */
 	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 


