From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Jun 2019 12:43:38 -0400
Subject: master - remove unused trustcache option
Message-ID: <201906111643.x5BGhcUi022261@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f350ba890f02eb73d6cdebe29420a709e2b5ae6
Commit:        0f350ba890f02eb73d6cdebe29420a709e2b5ae6
Parent:        c9203a6106c7f9d66d7872e5709f5e02d246c0e3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 11 11:42:49 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 11 11:42:49 2019 -0500

remove unused trustcache option

---
 lib/misc/lvm-globals.c |   11 -----------
 lib/misc/lvm-globals.h |    2 --
 tools/args.h           |    3 +--
 tools/command-lines.in |   10 +++++-----
 tools/lvmcmdline.c     |   11 -----------
 5 files changed, 6 insertions(+), 31 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 6d3bf02..eb99cf5 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -31,7 +31,6 @@ static int _fwraid_filtering = 0;
 static int _pvmove = 0;
 static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
 static enum dev_ext_e _external_device_info_source = DEV_EXT_NONE;
-static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _debug_classes_logged = 0;
 static int _security_level = SECURITY_LEVEL;
@@ -107,11 +106,6 @@ void init_external_device_info_source(enum dev_ext_e src)
 	_external_device_info_source = src;
 }
 
-void init_trust_cache(int trustcache)
-{
-	_trust_cache = trustcache;
-}
-
 void init_security_level(int level)
 {
 	_security_level = level;
@@ -285,11 +279,6 @@ enum dev_ext_e external_device_info_source(void)
 	return _external_device_info_source;
 }
 
-int trust_cache(void)
-{
-	return _trust_cache;
-}
-
 int background_polling(void)
 {
 	return _background_polling;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 944b822..921ae7e 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -32,7 +32,6 @@ void init_fwraid_filtering(int level);
 void init_pvmove(int level);
 void init_external_device_info_source(enum dev_ext_e src);
 void init_obtain_device_list_from_udev(int device_list_from_udev);
-void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_debug_classes_logged(int classes);
 void init_cmd_name(int status);
@@ -65,7 +64,6 @@ int fwraid_filtering(void);
 int pvmove_mode(void);
 int obtain_device_list_from_udev(void);
 enum dev_ext_e external_device_info_source(void);
-int trust_cache(void);
 int verbose_level(void);
 int silent_mode(void);
 int debug_level(void);
diff --git a/tools/args.h b/tools/args.h
index e972c7d..bd07aa3 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -713,9 +713,8 @@ arg(trackchanges_ARG, '\0', "trackchanges", 0, 0, 0,
     "merging the split image (see --mergemirrors) or permanently splitting\n"
     "the image (see --splitmirrors with --name.\n")
 
-/* TODO: hide this? */
 arg(trustcache_ARG, '\0', "trustcache", 0, 0, 0,
-    "Avoids certain device scanning during command processing. Do not use.\n")
+    "No longer used.\n")
 
 arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
     "The LV type, also known as \"segment type\" or \"segtype\".\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index c9d4fd6..73a1e64 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -198,7 +198,7 @@ OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
 --nameprefixes, --noheadings, --nosuffix,
 --options String, --readonly, --reportformat ReportFmt, --rows,
 --select String, --separator String, --shared, --sort String,
---trustcache, --unbuffered, --units Units, --unquoted
+--unbuffered, --units Units, --unquoted
 
 #
 # options for config, dumpconfig, lvmconfig
@@ -1384,7 +1384,7 @@ DESC: Resize a pool metadata SubLV by a specified size.
 lvs
 OO: --history, --segments, OO_REPORT
 OP: VG|LV|Tag ...
-IO: --partial, --ignoreskippedcluster
+IO: --partial, --ignoreskippedcluster, --trustcache
 ID: lvs_general
 
 ---
@@ -1486,7 +1486,7 @@ ID: pvremove_general
 pvs
 OO: --segments, OO_REPORT
 OP: PV|Tag ...
-IO: --partial, --ignoreskippedcluster
+IO: --partial, --ignoreskippedcluster, --trustcache
 ID: pvs_general
 
 ---
@@ -1752,7 +1752,7 @@ DESC: Rename a VG by specifying the VG UUID.
 vgs
 OO: OO_REPORT
 OP: VG|Tag ...
-IO: --partial, --ignoreskippedcluster
+IO: --partial, --ignoreskippedcluster, --trustcache
 ID: vgs_general
 
 ---
@@ -1807,7 +1807,7 @@ ID: devtypes_general
 fullreport
 OO: OO_REPORT
 OP: VG ...
-IO: --partial, --ignoreskippedcluster
+IO: --partial, --ignoreskippedcluster, --trustcache
 ID: fullreport_general
 
 lastlog
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 922c52d..3fec702 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2396,17 +2396,6 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (arg_is_set(cmd, binary_ARG))
 		cmd->report_binary_values_as_numeric = 1;
 
-	if (arg_is_set(cmd, trustcache_ARG)) {
-		if (arg_is_set(cmd, all_ARG)) {
-			log_error("--trustcache is incompatible with --all");
-			return EINVALID_CMD_LINE;
-		}
-		init_trust_cache(1);
-		log_warn("WARNING: Cache file of PVs will be trusted.  "
-			  "New devices holding PVs may get ignored.");
-	} else
-		init_trust_cache(0);
-
 	if (arg_is_set(cmd, noudevsync_ARG))
 		cmd->current_settings.udev_sync = 0;
 


