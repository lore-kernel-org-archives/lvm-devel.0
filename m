From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 14:51:23 +0000 (UTC)
Subject: master - libdm: config: fix dm_config_write_node and variants to properly return error on failures
Message-ID: <20160304145123.80CCA60AC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9720898c8ee3a4035858508b38179a143d948f4f
Commit:        9720898c8ee3a4035858508b38179a143d948f4f
Parent:        67c5006e12c9e3bf888db0fbaa78a50efcbfa9b2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 15:49:00 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 15:51:13 2016 +0100

libdm: config: fix dm_config_write_node and variants to properly return error on failures

The error was not propagated if _write_config (that is part of
dm_config_write_node and all its variants) was called recursively
for subsections.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-config.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d3eac29..109249a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.119 -
 =====================================
+  Fix dm_config_write_node and variants to return error on subsection failures.
   Remove 4096 char limit due to buffer size if writing dm_config_node.
 
 Version 1.02.118 - 26th February 2016
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 5fa06a1..dcb7c3f 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -366,7 +366,8 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 			line_append(" {");
 			if (!_line_end(n, out))
 				return_0;
-			_write_config(n->child, 0, out, level + 1);
+			if (!_write_config(n->child, 0, out, level + 1))
+				return_0;
 			if (!_line_start(out))
 				return_0;
 			line_append("%s}", space);


