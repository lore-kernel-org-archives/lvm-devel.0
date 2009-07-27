From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:02:19 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_base.c
Message-ID: <20090727210219.4604.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:02:19

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_base.c 

Log message:
	Add lvm_config_override - allow caller to override config, similar to --config.
	
	Allowing the caller to override the LVM configuration with an API will
	enable them to use things such as device filters.
	While very flexible, there is some danger to this API in that it will
	make it harder to debug setups that have a changing config and deduce
	what might have happened.  At some point we may want to limit the scope
	of this API but for now it is as open as the --config option to lvm commands.
	
	Update exported symbols.  When I renamed lvm_reload_config to lvm_config_reload
	I forgot to rename so I renamed that one here.
	
	This I believe is the last liblvm API for now.  ;-)
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/liblvm/.exported_symbols	2009/07/27 17:44:29	1.18
+++ LVM2/liblvm/.exported_symbols	2009/07/27 21:02:17	1.19
@@ -1,6 +1,7 @@
 lvm_create
 lvm_destroy
-lvm_reload_config
+lvm_config_reload
+lvm_config_override
 lvm_pv_get_name
 lvm_pv_get_uuid
 lvm_pv_get_mda_count
--- LVM2/liblvm/lvm.h	2009/07/27 21:00:50	1.31
+++ LVM2/liblvm/lvm.h	2009/07/27 21:02:17	1.32
@@ -149,6 +149,22 @@
 int lvm_config_reload(lvm_t libh);
 
 /**
+ * Override the LVM configuration with a configuration string.
+ *
+ * This API is equivalent to the --config option on lvm commands.
+ * FIXME: submit a patch to document the --config option
+ * Once this API has been used to over-ride the configuration,
+ * you should use lvm_config_reload to apply the new settings.
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ * \param   config_settings
+ *          LVM configuration string to apply.  See the lvm.conf file man page
+ *          for the format of the config string.
+ * \return  0 (success) or -1 (failure).
+ */
+int lvm_config_override(lvm_t libh, const char *config_string);
+
+/**
  * Return stored error no describing last LVM API error.
  *
  * Users of liblvm should use lvm_errno to determine success or failure
--- LVM2/liblvm/lvm_base.c	2009/07/27 10:18:51	1.6
+++ LVM2/liblvm/lvm_base.c	2009/07/27 21:02:17	1.7
@@ -72,6 +72,14 @@
 	return 0;
 }
 
+int lvm_config_override(lvm_t libh, const char *config_settings)
+{
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	if (override_config_tree_from_string(cmd, config_settings))
+		return -1;
+	return 0;
+}
+
 int lvm_errno(lvm_t libh)
 {
 	return stored_errno();


