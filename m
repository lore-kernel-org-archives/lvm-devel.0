From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 16:31:09 +0000 (UTC)
Subject: master - readline: switch to new-style readline typedef
Message-ID: <20140306163109.E4DA960DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=216c57eed72fee52e99bb5d014c9de535e631f58
Commit:        216c57eed72fee52e99bb5d014c9de535e631f58
Parent:        061acd177f4572f75107bac6a2f7379a55ceec93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 6 16:04:19 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 17:28:40 2014 +0100

readline: switch to new-style readline typedef

Based on patch:
https://www.redhat.com/archives/lvm-devel/2014-March/msg00015.html

The CPPFunction typedef (among others) have been deprecated in favour of
specific prototyped typedefs since readline 4.2 (circa 2001).
It's been working since because compatibility typedefs have been in
place until they where removed in the recent readline 6.3 release.
Switch to the new style to avoid build breakage.

But also add full backward compatibility with define.

Signed-off-by: Gustavo Zacarias <gustavo zacarias com ar>
---
 WHATS_NEW   |    1 +
 tools/lvm.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cfdc488..6e04327 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use correct rl_completion_func_t typedef for new readline.
   Make lvm 'dumpconfig --type default' complete for it to be consumed by lvm.
   Run pvscan --cache via systemd-run in udev if the PV label is detected lost.
   Fix memleak when lvmetad discovers PV to appear on another device.
diff --git a/tools/lvm.c b/tools/lvm.c
index 51e9293..f9ab438 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -27,6 +27,7 @@ int main(int argc, char **argv)
 #  include <readline/history.h>
 #  ifndef HAVE_RL_COMPLETION_MATCHES
 #    define rl_completion_matches(a, b) completion_matches((char *)a, b)
+#    define rl_completion_func_t CPPFunction
 #  endif
 
 static struct cmdline_context *_cmdline;
@@ -185,7 +186,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
 	rl_readline_name = "lvm";
-	rl_attempted_completion_function = (CPPFunction *) _completion;
+	rl_attempted_completion_function = (rl_completion_func_t *) _completion;
 
 	_read_history(cmd);
 


