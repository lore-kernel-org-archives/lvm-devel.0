From: Jim Meyering <jim@meyering.net>
Date: Thu, 14 Feb 2008 14:07:55 +0100
Subject: [PATCH] clvmd.c: Remove redundant if-before-free tests.
Message-ID: <871w7fit3o.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since "free (NULL);" is universally safe these days, I propose
to remove all of lvm's redundant "if-before-free" tests.
There are only 5.  If no one objects, I'll commit it tonight.

In case you need more justification than "POSIX requires it",
(understandable, that :-), the following was enough for Wine
development a year and a half ago:

    http://www.winehq.org/pipermail/wine-patches/2006-October/031544.html

Sure, the extra test is not a big deal, but removing it does make the
code slightly smaller, and maybe even more readable (people won't wonder
about the test of such a pointer, when they know that free can handle
a NULL pointer).

The changes in the patch below were created by running this command
after a fresh "clone":

  find . -name '*.c' -print0 | xargs -0 perl -0x3b -pi -e \
     's/\bif\s*\(\s*(\S+?)(?:\s*!=\s*NULL)?\s*\)\s+(free\s*\(\s*\1\s*\))/$2/s'

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 574010f..14ee1c6 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -903,8 +903,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 		}

 		/* Free the command buffer */
-		if (thisfd->bits.localsock.cmd)
-			free(thisfd->bits.localsock.cmd);
+		free(thisfd->bits.localsock.cmd);

 		/* Clear out the cross-link */
 		if (thisfd->bits.localsock.pipe_client != NULL)
@@ -939,8 +938,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 		}

 		/* Free any old buffer space */
-		if (thisfd->bits.localsock.cmd)
-			free(thisfd->bits.localsock.cmd);
+		free(thisfd->bits.localsock.cmd);

 		/* See if we have the whole message */
 		argslen =
@@ -1547,8 +1545,7 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 		}
 		thisreply = thisreply->next;

-		if (tempreply->replymsg)
-			free(tempreply->replymsg);
+		free(tempreply->replymsg);
 		free(tempreply);
 	}

@@ -1579,8 +1576,7 @@ static void free_reply(struct local_client *client)

 		thisreply = thisreply->next;

-		if (tempreply->replymsg)
-			free(tempreply->replymsg);
+		free(tempreply->replymsg);
 		free(tempreply);
 	}
 	client->bits.localsock.replies = NULL;
@@ -1732,8 +1728,7 @@ static __attribute__ ((noreturn)) void *lvm_thread_fn(void *arg)
 			pthread_mutex_unlock(&lvm_thread_mutex);

 			process_work_item(cmd);
-			if (cmd->msg)
-				free(cmd->msg);
+			free(cmd->msg);
 			free(cmd);

 			pthread_mutex_lock(&lvm_thread_mutex);
--
1.5.4.1.98.gf3293


