From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jun 2012 11:51:21 +0000 (UTC)
Subject: master - fix: use 64bit math for reserved memory
Message-ID: <20120622115121.E76BC169C@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=192fa11dab177027ad349363b39ff6435524b23d
Commit:        192fa11dab177027ad349363b39ff6435524b23d
Parent:        6f3cd63551db013e3cf5dfcebc41115322d5cfe9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 12:59:14 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 13:32:19 2012 +0200

fix: use 64bit math for reserved memory

If the user specifies number in the range of [4G/1024, 4G>,
the used value would wrap around (32bit math).
So keep the math 64bit.

Note, using such large lvm.conf values is pointless with lvm2.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 97bd680..ed1b37f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Use 64bit math for reserved memory and stack.
   Add tests for kernel_send() errors in cmirrod.
   Print clean_bits in pull_state, fix cut&paste typo in cmirrord.
   Add tests for errors from closedir(), close() in cmirrord.
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 8c631bf..17dee1c 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -446,12 +446,12 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 void memlock_init(struct cmd_context *cmd)
 {
 	/* When threaded, caller already limited stack size so just use the default. */
-	_size_stack = 1024 * (cmd->threaded ? DEFAULT_RESERVED_STACK :
-					      find_config_tree_int(cmd, "activation/reserved_stack",
-								   DEFAULT_RESERVED_STACK));
+	_size_stack = 1024ULL * (cmd->threaded ? DEFAULT_RESERVED_STACK :
+				 find_config_tree_int(cmd, "activation/reserved_stack",
+						      DEFAULT_RESERVED_STACK));
 	_size_malloc_tmp = find_config_tree_int(cmd,
 					   "activation/reserved_memory",
-					   DEFAULT_RESERVED_MEMORY) * 1024;
+					   DEFAULT_RESERVED_MEMORY) * 1024ULL;
 	_default_priority = find_config_tree_int(cmd,
 					    "activation/process_priority",
 					    DEFAULT_PROCESS_PRIORITY);


