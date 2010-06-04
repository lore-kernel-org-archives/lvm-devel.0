From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Jun 2010 12:59:36 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20100604125936.31553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-04 12:59:31

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c 

Log message:
	Fix restart of clvmd using -S switch
	
	- allocate environment dynamically (still missing some limit?)
	- try to recover, if destroy failed (do not destroy lvm here) and free memory
	- check strdup() return codes
	- report failure to log
	- do not print NULL in exclusive lock loop

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1606&r2=1.1607
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2010/06/03 21:03:53	1.1606
+++ LVM2/WHATS_NEW	2010/06/04 12:59:30	1.1607
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Handle failed restart of clvmd using -S switch properly.
   Fix clvmd initscript restart command to start clvmd if not yet running.
   Use absolute paths for clvmd restart.
   Require partial option in lvchange --refresh for partial LVs.
--- LVM2/daemons/clvmd/clvmd-command.c	2010/06/03 13:50:26	1.35
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/06/04 12:59:30	1.36
@@ -361,33 +361,51 @@
 
 static int restart_clvmd(void)
 {
-	char *argv[1024];
-	int argc = 1;
+	char **argv = NULL;
+	char *debug_arg = NULL, *lv_name;
+	int i, argc = 0, max_locks = 0;
 	struct dm_hash_node *hn = NULL;
-	char *lv_name;
 
 	DEBUGLOG("clvmd restart requested\n");
 
+	/* Count exclusively-open LVs */
+	hn = NULL;
+	do {
+		hn = get_next_excl_lock(hn, &lv_name);
+		if (lv_name)
+			max_locks++;
+	} while (hn && *lv_name);
+
+	/* clvmd + locks (-E uuid) + debug (-d X) + NULL */
+	argv = malloc((max_locks * 2 + 4) * sizeof(*argv));
+	if (!argv)
+		goto_out;
+
 	/*
 	 * Build the command-line
 	 */
-	/* FIXME missing strdup error checks */
-	argv[0] = strdup("clvmd");
+	argv[argc++] = strdup("clvmd");
+	if (!argv[0])
+		goto_out;
 
 	/* Propogate debug options */
 	if (debug) {
-		char debug_level[16];
-
-		sprintf(debug_level, "-d%d", debug);
-		argv[argc++] = strdup(debug_level);
+		if (!(debug_arg = malloc(16)) ||
+		    snprintf(debug_arg, 16, "-d%d", (int)debug) < 0)
+			goto_out;
+		argv[argc++] = debug_arg;
 	}
 
 	/* Now add the exclusively-open LVs */
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
 		if (lv_name) {
-			argv[argc++] = strdup("-E");
-			argv[argc++] = strdup(lv_name);
+			argv[argc] = strdup("-E");
+			if (!argv[argc++])
+				goto_out;
+			argv[argc] = strdup(lv_name);
+			if (!argv[argc++])
+				goto_out;
 
 			DEBUGLOG("excl lock: %s\n", lv_name);
 			hn = get_next_excl_lock(hn, &lv_name);
@@ -395,13 +413,16 @@
 	} while (hn && *lv_name);
 	argv[argc++] = NULL;
 
-	/* Tidy up */
-	destroy_lvm();
-
 	/* Exec new clvmd */
 	/* NOTE: This will fail when downgrading! */
 	execve(CLVMD_PATH, argv, NULL);
-
+out:
 	/* We failed */
+	DEBUGLOG("Restart of clvmd failed.\n");
+
+	for (i = 0; i < argc && argv[i]; i++)
+		free(argv[i]);
+	free(argv);
+
 	return 0;
 }
--- LVM2/daemons/clvmd/lvm-functions.c	2010/06/03 13:50:26	1.90
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/06/04 12:59:30	1.91
@@ -898,7 +898,9 @@
 			v = dm_hash_get_next(lv_hash, v);
 		}
 	} while (v && !*name);
-	DEBUGLOG("returning EXclusive UUID %s\n", *name);
+
+	if (*name)
+		DEBUGLOG("returning EXclusive UUID %s\n", *name);
 	return v;
 }
 


