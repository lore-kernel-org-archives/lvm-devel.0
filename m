From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 17:58:57 +0000 (UTC)
Subject: master - format_text: Store creation_host_system_id.
Message-ID: <20150223175857.0526961153@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc5e3dbf24f69df8f7410919df3a9f11988cee54
Commit:        cc5e3dbf24f69df8f7410919df3a9f11988cee54
Parent:        2a1189ebc34d640396b87be410642cc394d01f27
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 17:54:47 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 17:54:47 2015 +0000

format_text: Store creation_host_system_id.

Record the current system ID at the time of writing out VG metadata
in the outer section of it alongside the hostname and time.
---
 WHATS_NEW                |    1 +
 lib/format_text/export.c |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 92bb1aa..0ae007d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Record creation_host_system_id in lvm2 metadata.
   Reinstate recursive config file tag section processing. (2.02.99)
   Add 'lvm systemid' to display the current system ID.
   Fix configure to properly recognize --with-default-raid10-segtype option.
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index c2453f2..d853bb5 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -21,6 +21,7 @@
 #include "segtype.h"
 #include "text_export.h"
 #include "lvm-version.h"
+#include "toolcontext.h"
 
 #include <stdarg.h>
 #include <time.h>
@@ -327,7 +328,7 @@ int out_config_node(struct formatter *f, const struct dm_config_node *cn)
 	return dm_config_write_node(cn, _out_line, f);
 }
 
-static int _print_header(struct formatter *f,
+static int _print_header(struct cmd_context *cmd, struct formatter *f,
 			 const char *desc)
 {
 	char *buf;
@@ -350,6 +351,8 @@ static int _print_header(struct formatter *f,
 	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
 	     _utsname.sysname, _utsname.nodename, _utsname.release,
 	     _utsname.version, _utsname.machine);
+	if (cmd->system_id && *cmd->system_id)
+		outf(f, "creation_host_system_id = \"%s\"", dm_escape_double_quotes(buf, cmd->system_id));
 	outf(f, "creation_time = %lu\t# %s", t, ctime(&t));
 
 	return 1;
@@ -744,7 +747,7 @@ static int _text_vg_export(struct formatter *f,
 	if (!_build_pv_names(f, vg))
 		goto_out;
 
-	if (f->header && !_print_header(f, desc))
+	if (f->header && !_print_header(vg->cmd, f, desc))
 		goto_out;
 
 	if (!out_text(f, "%s {", vg->name))
@@ -767,7 +770,7 @@ static int _text_vg_export(struct formatter *f,
 	if (!out_text(f, "}"))
 		goto_out;
 
-	if (!f->header && !_print_header(f, desc))
+	if (!f->header && !_print_header(vg->cmd, f, desc))
 		goto_out;
 
 	r = 1;


