From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:50:00 +0000 (GMT)
Subject: dev-next - system_id: new appmachineid option
Message-ID: <20210331215000.78ED83858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40fb0b1650865aa52962faae759d16c1abe35765
Commit:        40fb0b1650865aa52962faae759d16c1abe35765
Parent:        3008dade3a2237b5fbde0e733cde6eff6d8e2a0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 20 10:59:38 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 31 16:47:05 2021 -0500

system_id: new appmachineid option

The new system_id_source="appmachineid" will cause
lvm to use an lvm-specific derivation of the machine-id,
instead of the machine-id directly.  This is now
recommended in place of using machineid.
---
 configure.ac                 | 20 ++++++++++++++++++++
 lib/commands/toolcontext.c   | 26 +++++++++++++++++++++++---
 lib/config/config_settings.h |  8 +++++---
 man/lvmsystemid.7_main       | 23 +++++++++++++++++++----
 test/shell/system_id.sh      | 11 +++++++++++
 5 files changed, 78 insertions(+), 10 deletions(-)

diff --git a/configure.ac b/configure.ac
index 21a1d311e..cfa67eadb 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1073,6 +1073,26 @@ if test "$NOTIFYDBUS_SUPPORT" = yes; then
 	PKG_CHECK_MODULES(NOTIFY_DBUS, systemd >= 221, [HAVE_NOTIFY_DBUS=yes], $bailout)
 fi
 
+################################################################################
+dnl -- Build appmachineid
+AC_MSG_CHECKING(whether to build appmachineid)
+AC_ARG_ENABLE(app-machineid,
+	      AC_HELP_STRING([--enable-app-machineid],
+			     [enable LVM system ID using app-specific machine-id]),
+	      APP_MACHINEID_SUPPORT=$enableval, APP_MACHINEID_SUPPORT=no)
+AC_MSG_RESULT($APP_MACHINEID_SUPPORT)
+
+if test "$APP_MACHINEID_SUPPORT" = yes; then
+	AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.])
+	SYSTEMD_LIBS="-lsystemd"
+fi
+
+################################################################################
+dnl -- Look for libsystemd libraries
+if test "$APP_MACHINEID_SUPPORT" = yes; then
+	PKG_CHECK_MODULES(APP_MACHINEID, systemd >= 234, [HAVE_APP_MACHINEID=yes], $bailout)
+fi
+
 ################################################################################
 
 dnl -- Enable blkid wiping functionality
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 75634caff..91701b2bd 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -41,6 +41,10 @@
 #include <syslog.h>
 #include <time.h>
 
+#ifdef APP_MACHINEID_SUPPORT
+#include <systemd/sd-id128.h>
+#endif
+
 #ifdef __linux__
 #  include <malloc.h>
 #endif
@@ -129,9 +133,12 @@ static const char *_read_system_id_from_file(struct cmd_context *cmd, const char
 	return system_id;
 }
 
+/* systemd-id128 new produced: f64406832c2140e8ac5422d1089aae03 */
+#define LVM_APPLICATION_ID SD_ID128_MAKE(f6,44,06,83,2c,21,40,e8,ac,54,22,d1,08,9a,ae,03)
+
 static const char *_system_id_from_source(struct cmd_context *cmd, const char *source)
 {
-	char filebuf[PATH_MAX];
+	char buf[PATH_MAX];
 	const char *file;
 	const char *etc_str;
 	const char *str;
@@ -150,10 +157,23 @@ static const char *_system_id_from_source(struct cmd_context *cmd, const char *s
 		goto out;
 	}
 
+#ifdef APP_MACHINEID_SUPPORT
+	if (!strcasecmp(source, "appmachineid")) {
+		sd_id128_t id;
+
+		sd_id128_get_machine_app_specific(LVM_APPLICATION_ID, &id);
+
+		if (dm_snprintf(buf, PATH_MAX, SD_ID128_FORMAT_STR, SD_ID128_FORMAT_VAL(id)) < 0)
+			stack;
+		system_id = system_id_from_string(cmd, buf);
+		goto out;
+	}
+#endif
+
 	if (!strcasecmp(source, "machineid") || !strcasecmp(source, "machine-id")) {
 		etc_str = find_config_tree_str(cmd, global_etc_CFG, NULL);
-		if (dm_snprintf(filebuf, sizeof(filebuf), "%s/machine-id", etc_str) != -1)
-			system_id = _read_system_id_from_file(cmd, filebuf);
+		if (dm_snprintf(buf, sizeof(buf), "%s/machine-id", etc_str) != -1)
+			system_id = _read_system_id_from_file(cmd, buf);
 		goto out;
 	}
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index af6a1f4f1..0838bccc2 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1275,10 +1275,12 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, CFG_DEF
 	"  uname\n"
 	"    Set the system ID from the hostname (uname) of the system.\n"
 	"    System IDs beginning localhost are not permitted.\n"
+	"  appmachineid\n"
+	"    Use an LVM-specific derivation of the local machine-id as the\n"
+	"    system ID. See 'man machine-id'.\n"
 	"  machineid\n"
-	"    Use the contents of the machine-id file to set the system ID.\n"
-	"    Some systems create this file@installation time.\n"
-	"    See 'man machine-id' and global/etc.\n"
+	"    Use the contents of the machine-id file to set the system ID\n"
+	"    (appmachineid is recommended.)\n"
 	"  file\n"
 	"    Use the contents of another file (system_id_file) to set the\n"
 	"    system ID.\n"
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 7d6e96ed6..e079643ab 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -112,7 +112,7 @@ version without the system ID feature.
 
 A local VG is meant to be used by a single host.
 
-A shared or clustered VG is meant to be used by multiple hosts.
+A shared VG is meant to be used by multiple hosts.
 
 These can be further distinguished as:
 
@@ -168,16 +168,31 @@ global {
 }
 .fi
 
+.TP
+.B appmachineid
+.br
+
+An LVM-specific derivation of /etc/machine-id is used as the system ID.
+See
+.BR machine-id (5)
+to check if machine-id is available on the host.
+
+.I lvm.conf
+.nf
+global {
+    system_id_source = "appmachineid"
+}
+.fi
+
 .TP
 .B machineid
 .br
 
-The content of /etc/machine-id is used as the system ID if available.
+The content of /etc/machine-id is used as the system ID.
 See
 .BR machine-id (5)
-and
-.BR systemd-machine-id-setup (1)
 to check if machine-id is available on the host.
+(appmachineid is recommended in place of machineid.)
 
 .I lvm.conf
 .nf
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 8814d5497..8b5638af3 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -50,6 +50,17 @@ check vg_field $vg1 systemid "$SID"
 vgremove $vg1
 fi
 
+## appmachineid
+lvm version > lvmver
+if grep app-machineid lvmver; then
+aux lvmconf "global/system_id_source = appmachineid"
+lvm systemid | awk '{ print $3 }' > sid_lvm
+vgcreate $vg1 "$dev1"
+vgs -o systemid --noheadings $vg1 | awk '{print $1}' > sid_vg
+diff sid_lvm sid_vg
+vgremove $vg1
+fi
+
 ## uname
 
 SID1=$(uname -n)


