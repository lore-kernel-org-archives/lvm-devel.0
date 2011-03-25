From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Mar 2011 22:57:46 +0100
Subject: [PATCH 2/3] Set our own in/out buffers
In-Reply-To: <cover.1301089240.git.zkabelac@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>
Message-ID: <49609a18834f11b833c31a164a2b467dd52095f3.1301089240.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Memory lock from critical_section is now being kept over the critical
section - mallopt() should ensure, that mmap is not used for allocation,
and we preallocate some memory to be able to satisfy some small
alloc request. However when glibc needs buffers for line buffering of
input and output buffers - it allocates these buffers in such way it
adds memory page for each such buffer and size of unlock memory check will
mismatch by 1 or 2 pages.

This happens when we print or read lines without '\n' so these buffers
are used. To avoid this extra allocation, use setvbuf to set these
bufffers ahead.

FIXME: Bigger fix is needs to avoid quering users while holding VG
locks, as such question might take quite some time....
Thus should in effect unlock memory before displaying such message.
But some more work needs to be done for this - so hack for now.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 30c8fc6..be2ba5c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1129,6 +1129,8 @@ static void _init_globals(struct cmd_context *cmd)
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir)
 {
+    	static char inbuf[4096];
+	static char outbuf[4096];
 	struct cmd_context *cmd;
 
 #ifdef M_MMAP_MAX
@@ -1159,6 +1161,12 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 
+        /* Set in/out line buffers before glibc */
+	if (setvbuf(stdin, inbuf, _IOLBF, sizeof(inbuf)) != 0)
+		log_sys_error("setvbuf", "in");
+	if (setvbuf(stdout, outbuf, _IOLBF, sizeof(outbuf)) != 0)
+		log_sys_error("setvbuf", "out");
+
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
 
-- 
1.7.4.1


