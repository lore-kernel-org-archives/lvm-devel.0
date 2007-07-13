From: Jim Meyering <jim@meyering.net>
Date: Fri, 13 Jul 2007 23:40:15 +0200
Subject: avoid trouble with failed strdup
In-Reply-To: <87sl7vowgr.fsf@rho.meyering.net> (Jim Meyering's message of
	"Wed\, 11 Jul 2007 16\:18\:12 +0200")
References: <87sl7vowgr.fsf@rho.meyering.net>
Message-ID: <87odigdlts.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jim Meyering <jim@meyering.net> wrote:
> There are three uses of basename in the lvm2/cvs tree.  The two uses
> in lvmcmdline.c operate on strdup'd copies, presumably to avoid the
> portability problem whereby an old basename implementation would modify
> its argument string.  The third use (in tools/fsadm/fsadm.c) operates
> on a "const" string but has no such protection.  Here's one of the uses
> from lvmcmdline.c:
>
>        namebase = strdup(name);
>        base = basename(namebase);

Alasdair and I talked about how to do this, and here's what
I understood is desired:

The proposed log entry:

  Eliminate uses of strdup+basename.  Use last_component instead.
  * tools/fsadm/fsadm.c: Include "last-component.h".
  (_usage): Use last_component, not basename.
  * tools/lvmcmdline.c (_find_command, lvm2_main): Likewise.
  * lib/misc/last-component.h: New file, derived from gnulib's basename.c
  * include/.symlinks: Add lib/misc/last-component.h.
  * WHATS_NEW: Mention this.

The corresponding patch:

diff --git a/WHATS_NEW b/WHATS_NEW
index 56f579e..a35e005 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Eliminate uses of strdup+basename.  Use last_component instead.
   Fix configure libdevmapper.h check when --with-dmdir is used.
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
   Add pv_by_path() external library function.
diff --git a/include/.symlinks b/include/.symlinks
index 2fa755a..ccf6c34 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -37,6 +37,7 @@
 ../lib/misc/configure.h
 ../lib/misc/crc.h
 ../lib/misc/intl.h
+../lib/misc/last-component.h
 ../lib/misc/lib.h
 ../lib/misc/lvm-exec.h
 ../lib/misc/lvm-file.h
diff --git a/lib/misc/last-component.h b/lib/misc/last-component.h
new file mode 100644
index 0000000..0618a17
--- /dev/null
+++ b/lib/misc/last-component.h
@@ -0,0 +1,38 @@
+/* This function is derived from gnulib's basename.c */
+
+/*
+ * Copyright (C) 2007 Free Software Foundation, Inc.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/* Return the address of the last file name component of NAME.  If
+   NAME has no relative file name components because it is a file
+   system root, return the empty string.  */
+
+static inline char *
+last_component(char const *name)
+{
+	char const *p;
+	int saw_slash = 0;
+
+	while (*name == '/')
+		name++;
+
+	for (p = name; *p; p++) {
+		if (*p == '/')
+			saw_slash = 1;
+		else if (saw_slash) {
+			name = p;
+			saw_slash = 0;
+		}
+	}
+
+	return (char *) name;
+}
diff --git a/tools/fsadm/fsadm.c b/tools/fsadm/fsadm.c
index 61e428c..948b875 100644
--- a/tools/fsadm/fsadm.c
+++ b/tools/fsadm/fsadm.c
@@ -32,6 +32,8 @@
 #include <sys/mount.h>
 #include <sys/vfs.h>

+#include "last-component.h"
+
 #define log_error(str, x...) fprintf(stderr, "%s(%u):  " str "\n", __FILE__, __LINE__, x)

 /* Filesystem related information */
@@ -45,7 +47,7 @@ struct fsinfo {
 static void _usage(const char *cmd)
 {
 	log_error("Usage: %s [check <filesystem> | resize <filesystem> <size>]",
-		  basename(cmd));
+		  last_component(cmd));
 }

 /* FIXME Make this more robust - /proc, multiple mounts, TMPDIR + security etc. */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 039eb51..276a381 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -20,6 +20,7 @@

 #include "stub.h"
 #include "lvm2cmd.h"
+#include "last-component.h"

 #include <signal.h>
 #include <syslog.h>
@@ -479,18 +480,15 @@ void lvm_register_commands(void)
 static struct command *_find_command(const char *name)
 {
 	int i;
-	char *namebase, *base;
+	char *base;

-	namebase = strdup(name);
-	base = basename(namebase);
+	base = last_component(name);

 	for (i = 0; i < _cmdline.num_commands; i++) {
 		if (!strcmp(base, _cmdline.commands[i].name))
 			break;
 	}

-	free(namebase);
-
 	if (i >= _cmdline.num_commands)
 		return 0;

@@ -1138,14 +1136,13 @@ static void _exec_lvm1_command(char **argv)

 int lvm2_main(int argc, char **argv, unsigned is_static)
 {
-	char *namebase, *base;
+	char *base;
 	int ret, alias = 0;
 	struct cmd_context *cmd;

 	_close_stray_fds();

-	namebase = strdup(argv[0]);
-	base = basename(namebase);
+	base = last_component(argv[0]);
 	while (*base == '/')
 		base++;
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
@@ -1160,8 +1157,6 @@ int lvm2_main(int argc, char **argv, unsigned is_static)
 		unsetenv("LVM_DID_EXEC");
 	}

-	free(namebase);
-
 	if (!(cmd = init_lvm(is_static)))
 		return -1;


