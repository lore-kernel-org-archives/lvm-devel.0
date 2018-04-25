From: Han Han <hhan@redhat.com>
Date: Wed, 25 Apr 2018 14:10:06 +0800
Subject: [PATCH] Fix memory leak in function create_toolcontext
Message-ID: <20180425061006.23879-1-hhan@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Close stdin and stdout file handlers before create_toolcontext returns.

Signed-off-by: Han Han <hhan@redhat.com>
---
 lib/commands/toolcontext.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a54f4d7b5..f81743540 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1838,6 +1838,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 {
 	struct cmd_context *cmd;
 	int flags;
+    FILE **stdin_stream = NULL;
+    FILE **stdout_stream = NULL;
 
 #ifdef M_MMAP_MAX
 	mallopt(M_MMAP_MAX, 0);
@@ -1892,7 +1894,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		if (is_valid_fd(STDIN_FILENO) &&
 		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_WRONLY) {
-			if (!reopen_standard_stream(&stdin, "r"))
+			if (!reopen_standard_stream(stdin_stream=&stdin, "r"))
 				goto_out;
 			if (setvbuf(stdin, cmd->linebuffer, _IOLBF, _linebuffer_size)) {
 				log_sys_error("setvbuf", "");
@@ -1903,7 +1905,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		if (is_valid_fd(STDOUT_FILENO) &&
 		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_RDONLY) {
-			if (!reopen_standard_stream(&stdout, "w"))
+			if (!reopen_standard_stream(stdin_stream=&stdout, "w"))
 				goto_out;
 			if (setvbuf(stdout, cmd->linebuffer + _linebuffer_size,
 				     _IOLBF, _linebuffer_size)) {
@@ -2015,6 +2017,14 @@ out:
 		cmd = NULL;
 	}
 
+    if (stdin_stream != NULL){
+        fclose(*stdin_stream);
+    }
+
+    if (stdout_stream != NULL){
+        fclose(*stdin_stream);
+    }
+
 	return cmd;
 }
 
-- 
2.17.0


