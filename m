From: Ondrej Kozina <okozina@sourceware.org>
Date: Fri, 10 Nov 2017 09:23:32 -0500
Subject: master - dmsetup: hide integrity encryption keys on table output
Message-ID: <201711101423.vAAENWTd025231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32e747dd3124a2de6b2d07e0494067dd0147932b
Commit:        32e747dd3124a2de6b2d07e0494067dd0147932b
Parent:        512b2adc7773d302895d01dbc1bccfb66dd94d6a
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Nov 10 13:55:04 2017 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri Nov 10 15:23:00 2017 +0100

dmsetup: hide integrity encryption keys on table output

---
 WHATS_NEW_DM       |    1 +
 man/dmsetup.8_main |    6 ++--
 tools/dmsetup.c    |   60 ++++++++++++++++++++++++++++++++++++++-------------
 3 files changed, 48 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 71ccea7..b7f71ca 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.146 -
 ====================================
+  Suppress integrity encryption keys in 'table' output unless --showkeys supplied.
 
 Version 1.02.145 - 3rd November 2017
 ====================================
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 054746c..8317e23 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -842,10 +842,10 @@ Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
 With \fB--target\fP, only information relating to the specified target type
 is displayed.
-Real encryption keys are suppressed in the table output for the crypt
-target unless the \fB--showkeys\fP parameter is supplied. Kernel key
+Real encryption keys are suppressed in the table output for crypt and integrity
+targets unless the \fB--showkeys\fP parameter is supplied. Kernel key
 references prefixed with \fB:\fP are not affected by the parameter and get
-displayed always.
+displayed always (crypt target only).
 With \fB--concise\fP, the output is presented concisely on a single line.
 Commas then separate the name, uuid, minor device number, flags ('ro' or 'rw')
 and the table (if present). Semi-colons separate devices. Backslashes escape
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ced0311..e85680f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2375,6 +2375,24 @@ static void _print_string_quoted(const char *s)
 	}
 }
 
+static void hide_key(char *params, const char *name)
+{
+	char *c = strstr(params, name);
+
+	if (!c)
+		return;
+
+	c += strlen(name);
+
+	/* key is optional */
+	c = strpbrk(c, " :");
+	if (!c || *c++ != ':')
+		return;
+
+	while (*c && *c != ' ')
+		*c++ = '0';
+}
+
 static int _status(CMD_ARGS)
 {
 	int r = 0;
@@ -2480,24 +2498,34 @@ static int _status(CMD_ARGS)
 			}
 			/* Next print any target-specific information */
 			if (target_type) {
-				/* Suppress encryption key */
+				/* Suppress encryption keys */
 				if (!_switches[SHOWKEYS_ARG] &&
-				    cmdno == DM_DEVICE_TABLE &&
-				    !strcmp(target_type, "crypt")) {
-					c = params;
-					while (*c && *c != ' ')
-						c++;
-					if (*c)
-						c++;
-					/*
-					 * Do not suppress kernel key references prefixed
-					 * with colon ':'. Displaying those references is
-					 * harmless. crypt target supports kernel keys
-					 * starting with v1.15.0 (merged in kernel 4.10)
-					 */
-					if (*c != ':')
+				    cmdno == DM_DEVICE_TABLE) {
+					if (!strcmp(target_type, "crypt")) {
+						c = params;
 						while (*c && *c != ' ')
-							*c++ = '0';
+							c++;
+						if (*c)
+							c++;
+						/*
+						 * Do not suppress kernel key references prefixed
+						 * with colon ':'. Displaying those references is
+						 * harmless. crypt target supports kernel keys
+						 * starting with v1.15.0 (merged in kernel 4.10)
+						 */
+						if (*c != ':')
+							while (*c && *c != ' ')
+								*c++ = '0';
+					} else if (!strcmp(target_type, "integrity")) {
+						/*
+						 * "internal_hash", "journal_crypt" and "journal_mac"
+						 *  params allow keys optionally in hexbyte
+						 *  representation.
+						 */
+						hide_key(params, "internal_hash:");
+						hide_key(params, "journal_crypt:");
+						hide_key(params, "journal_mac:");
+					}
 				}
 				if (use_concise)
 					putchar(',');


