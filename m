From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2012 17:12:06 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20120314171206.9402.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-14 17:12:06

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : dev_manager.c 
	lib/config     : defaults.h 

Log message:
	Improve thin_check option passing
	
	Update a way we handle option passing - so we now support path and options
	with space inside.
	Fix dm name usage for thin pools with '-' in name.
	Use new lvm.conf option thin_check_options to pass in options as string array.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2355&r2=1.2356
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.275&r2=1.276
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW	2012/03/14 17:09:00	1.2355
+++ LVM2/WHATS_NEW	2012/03/14 17:12:05	1.2356
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Improve thin_check option passing and use configured path.
   Add --with-thin-check configure option for path to thin_check.
   Detect lvm binary path in lvmetad udev rules.
   Fix error message when pvmove LV activation fails with name already in use.
--- LVM2/doc/example.conf.in	2012/03/02 21:49:43	1.45
+++ LVM2/doc/example.conf.in	2012/03/14 17:12:05	1.46
@@ -658,7 +658,11 @@
     # The thin tools are available as part of the device-mapper-persistent-data
     # package from https://github.com/jthornber/thin-provisioning-tools.
     #
-    thin_check_executable = "/sbin/thin_check -q"
+    thin_check_executable = "@THIN_CHECK_CMD@"
+
+    # String with options passed with thin_check command. By default,
+    # option '-q' is for quite output.
+    thin_check_options = [ "-q", 121e321 ]
 
     # While activating devices, I/O to devices being (re)configured is
     # suspended, and as a precaution against deadlocks, LVM2 needs to pin
--- LVM2/lib/activate/dev_manager.c	2012/03/05 15:05:25	1.275
+++ LVM2/lib/activate/dev_manager.c	2012/03/14 17:12:05	1.276
@@ -1205,39 +1205,55 @@
 	int ret, status;
 	const struct thin_cb_data *data = cb_data;
 	const char *dmdir = dm_dir();
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	const char *thin_check =
 		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd,
 						 "global/thin_check_executable",
-						 DEFAULT_THIN_CHECK_EXECUTABLE);
+						 THIN_CHECK_CMD);
 	const struct logical_volume *mlv = first_seg(data->pool_lv)->metadata_lv;
-	size_t len = strlen(dmdir) + strlen(mlv->vg->name) + strlen(mlv->name) + 3;
+	size_t len = strlen(dmdir) + 2 * (strlen(mlv->vg->name) + strlen(mlv->name)) + 3;
 	char meta_path[len];
-	int args;
-	char *argv[19]; /* Max supported 15 args */
-	char *split;
+	int args = 0;
+	const char *argv[19]; /* Max supported 15 args */
+	char *split, *dm_name;
 
 	if (!thin_check[0])
 		return 1; /* Checking disabled */
 
-	if (dm_snprintf(meta_path, len, "%s/%s-%s", dmdir,
-			mlv->vg->name, mlv->name) < 0) {
+	if (!(dm_name = dm_build_dm_name(data->dm->mem, mlv->vg->name,
+					 mlv->name, NULL)) ||
+	    (dm_snprintf(meta_path, len, "%s/%s", dmdir, dm_name) < 0)) {
 		log_error("Failed to build thin metadata path.");
 		return 0;
 	}
 
-	if (!(split = dm_pool_strdup(data->dm->mem, thin_check))) {
-		log_error("Failed to duplicate thin check string.");
-		return 0;
+	if ((cn = find_config_tree_node(mlv->vg->cmd, "global/thin_check_options"))) {
+		for (cv = cn->v; cv && args < 16; cv = cv->next) {
+			if (cv->type != DM_CFG_STRING) {
+				log_error("Invalid string in config file: "
+					  "global/thin_check_options");
+				return 0;
+			}
+			argv[++args] = cv->v.str;
+		}
+	} else {
+		/* Use default options (no support for options with spaces) */
+		if (!(split = dm_pool_strdup(data->dm->mem, DEFAULT_THIN_CHECK_OPTIONS))) {
+			log_error("Failed to duplicate thin check string.");
+			return 0;
+		}
+		args = dm_split_words(split, 16, 0, (char**) argv + 1);
 	}
 
-	args = dm_split_words(split, 16, 0, argv);
-
 	if (args == 16) {
 		log_error("Too many options for thin check command.");
 		return 0;
 	}
-	argv[args++] = meta_path;
-	argv[args] = NULL;
+
+	argv[0] = thin_check;
+	argv[++args] = meta_path;
+	argv[++args] = NULL;
 
 	if (!(ret = exec_cmd(data->pool_lv->vg->cmd, (const char * const *)argv,
 			     &status, 0))) {
@@ -1262,7 +1278,7 @@
 		 */
 	}
 
-	dm_pool_free(data->dm->mem, split);
+	dm_pool_free(data->dm->mem, dm_name);
 
 	return ret;
 }
--- LVM2/lib/config/defaults.h	2012/03/05 14:19:14	1.98
+++ LVM2/lib/config/defaults.h	2012/03/14 17:12:06	1.99
@@ -64,7 +64,7 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
-#define DEFAULT_THIN_CHECK_EXECUTABLE  "/sbin/thin_check -q"
+#define DEFAULT_THIN_CHECK_OPTIONS "-q"
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */


