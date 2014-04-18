From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:54:54 +0000 (UTC)
Subject: master - unknown: fix mempool used for name allocation
Message-ID: <20140418145454.0939B60EC0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47a60369a0473bb5f4f8a9d153c83d1a3f4f187d
Commit:        47a60369a0473bb5f4f8a9d153c83d1a3f4f187d
Parent:        b5f8f452ac563ef07513e770b3202c6dc209443c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 10:42:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:47 2014 +0200

unknown: fix mempool used for name allocation

Use cmd libmem mempool for name allocation, since mem mempool
is released after each clvmd command.
---
 WHATS_NEW                     |    1 +
 lib/unknown/unknown.c         |    2 +-
 test/shell/unknown-segment.sh |    4 ++++
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dfa50e8..e7c9b04 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use proper libmem mempool for allocation of unknown segment name.
   Add --readonly to reporting and display tools for lock-free metadata access.
   Add locking_type 5 for dummy locking for tools that do not need any locks.
   Fix _recover_vg() error path when lock conversion fails.
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index f2a65eb..848a369 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -95,7 +95,7 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *n
 
 	segtype->cmd = cmd;
 	segtype->ops = &_unknown_ops;
-	segtype->name = dm_pool_strdup(cmd->mem, name);
+	segtype->name = dm_pool_strdup(cmd->libmem, name);
 	segtype->private = NULL;
 	segtype->flags = SEG_UNKNOWN | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index 8ec48d2..b4a5dfd 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -23,6 +23,10 @@ vgcfgrestore -f bak0 $vg
 # we have on-disk metadata with unknown segments now
 not lvchange -aey $vg/$lv1 # check that activation is refused
 
+# try once more to catch invalid memory access with valgrind
+# when clvmd flushes cmd mem pool
+not lvchange -aey $vg/$lv1 # check that activation is refused
+
 vgcfgbackup -f bak1 $vg
 cat bak1
 sed -e 's,unstriped,striped,;s,unmirror,mirror,' -i.orig bak1


