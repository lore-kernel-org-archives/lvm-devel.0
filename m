From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 21 Sep 2011 13:36:44 +0200
Subject: [PATCH 2/2] Clvmd restart cleanup
In-Reply-To: <cover.1316604772.git.zkabelac@redhat.com>
References: <cover.1316604772.git.zkabelac@redhat.com>
Message-ID: <92669d71c38c24b0e04fe564821330efc606f845.1316604772.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch tries to fix Clang warning about possible access via lv_name NULL pointer.

Also replaces allocation of memory (strdup) with just pointer assigment
(since we are going to call execve anyway).

Also check for  !lv_name only when lv_name is defined
(and as I'm not quite sure what state this really is - putting a FIXME
arround - since this rather looks like some expected situation ??).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |   42 ++++++++++++++++++----------------------
 1 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index c83e2cf..597fb6e 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -362,38 +362,39 @@ void cmd_client_cleanup(struct local_client *client)
 static int restart_clvmd(void)
 {
 	char **argv = NULL;
-	char *debug_arg = NULL, *lv_name;
-	int i, argc = 0, max_locks = 0;
+	char *lv_name;
+	int argc = 0, max_locks = 0;
 	struct dm_hash_node *hn = NULL;
+	char debug_arg[16];
+	char e_arg[] = "-E";
+	char clvmd_arg[] = "clvmd";
 
 	DEBUGLOG("clvmd restart requested\n");
 
 	/* Count exclusively-open LVs */
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
-		if (lv_name)
+		if (lv_name) {
 			max_locks++;
-	} while (hn && *lv_name);
+			if (!*lv_name)
+				break; /* FIXME: Is this error ? */
+		}
+	} while (hn);
 
 	/* clvmd + locks (-E uuid) + debug (-d X) + NULL */
-	argv = malloc((max_locks * 2 + 4) * sizeof(*argv));
-	if (!argv)
+	if (!(argv = malloc((max_locks * 2 + 4) * sizeof(*argv))))
 		goto_out;
 
 	/*
 	 * Build the command-line
 	 */
-	argv[argc++] = strdup("clvmd");
-	if (!argv[0])
-		goto_out;
+	argv[argc++] = clvmd_arg;
 
 	/* Propogate debug options */
 	if (clvmd_get_debug()) {
-		if (!(debug_arg = malloc(16)) ||
-		    dm_snprintf(debug_arg, 16, "-d%u", clvmd_get_debug()) < 0)
+		if (dm_snprintf(debug_arg, sizeof(debug_arg), "-d%u", clvmd_get_debug()) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
-		debug_arg = NULL;
 	}
 
 	/*
@@ -406,30 +407,25 @@ static int restart_clvmd(void)
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
 		if (lv_name) {
-			argv[argc] = strdup("-E");
-			if (!argv[argc++])
-				goto_out;
-			argv[argc] = strdup(lv_name);
-			if (!argv[argc++])
-				goto_out;
-
+			if (!*lv_name)
+				break; /* FIXME: Is this error ? */
+			argv[argc++] = e_arg;
+			argv[argc++] = lv_name;
 			DEBUGLOG("excl lock: %s\n", lv_name);
 		}
-	} while (hn && *lv_name);
+	} while (hn);
 	argv[argc++] = NULL;
 
 	/* Exec new clvmd */
 	DEBUGLOG("--- Restarting %s ---\n", CLVMD_PATH);
+
 	/* NOTE: This will fail when downgrading! */
 	execve(CLVMD_PATH, argv, NULL);
 out:
 	/* We failed */
 	DEBUGLOG("Restart of clvmd failed.\n");
 
-	for (i = 0; i < argc && argv[i]; i++)
-		free(argv[i]);
 	free(argv);
-	free(debug_arg);
 
 	return EIO;
 }
-- 
1.7.6.2


