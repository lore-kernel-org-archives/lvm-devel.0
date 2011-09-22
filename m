From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Sep 2011 09:47:34 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20110922094734.13600.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-22 09:47:34

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Clvmd restart cleanup
	
	Patch fixes Clang warnings about possible access via lv_name NULL pointer.
	
	Replaces allocation of memory (strdup) with just pointer assignment
	(since execve is being called anyway).
	
	Checks for  !*lv_name only when lv_name is defined.
	(and as I'm not quite sure what state this really is - putting a FIXME
	around - as this rather looks suspicios ??).
	
	Add debug print of passed clvmd args.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2128&r2=1.2129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2011/09/22 09:45:24	1.2128
+++ LVM2/WHATS_NEW	2011/09/22 09:47:34	1.2129
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Cleanup restart clvmd code (no memory allocation, debug print passed args).
   Add all exclusive locks to clvmd restart option args.
   Always send the whole clvmd packet header in refresh commands.
   Add missing error checks for some system calls in cmirrord.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/09/22 09:45:24	1.57
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/09/22 09:47:34	1.58
@@ -361,39 +361,38 @@
 
 static int restart_clvmd(void)
 {
-	char **argv = NULL;
-	char *debug_arg = NULL, *lv_name;
-	int i, argc = 0, max_locks = 0;
+	const char **argv;
+	char *lv_name;
+	int argc = 0, max_locks = 0;
 	struct dm_hash_node *hn = NULL;
+	char debug_arg[16];
 
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
+	argv[argc++] = "clvmd";
 
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
@@ -406,30 +405,26 @@
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
+			argv[argc++] = "-E";
+			argv[argc++] = lv_name;
 			DEBUGLOG("excl lock: %s\n", lv_name);
 		}
-	} while (hn && *lv_name);
-	argv[argc++] = NULL;
+	} while (hn);
+	argv[argc] = NULL;
 
 	/* Exec new clvmd */
 	DEBUGLOG("--- Restarting %s ---\n", CLVMD_PATH);
+	for (argc = 1; argv[argc]; argc++) DEBUGLOG("--- %d: %s\n", argc, argv[argc]);
+
 	/* NOTE: This will fail when downgrading! */
-	execve(CLVMD_PATH, argv, NULL);
+	execve(CLVMD_PATH, (char **)argv, NULL);
 out:
 	/* We failed */
 	DEBUGLOG("Restart of clvmd failed.\n");
 
-	for (i = 0; i < argc && argv[i]; i++)
-		free(argv[i]);
 	free(argv);
-	free(debug_arg);
 
 	return EIO;
 }


