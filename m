From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 16:01:47 -0400
Subject: [PATCH] Add lvm_config_override - allow caller to override config, similar to --config.
In-Reply-To: <1248724909-20369-4-git-send-email-dwysocha@redhat.com>
References: <1248724909-20369-1-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-2-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-3-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1248724909-20369-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
---
 liblvm/.exported_symbols |    3 ++-
 liblvm/lvm.h             |   16 ++++++++++++++++
 liblvm/lvm_base.c        |    8 ++++++++
 3 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 68edb87..3e51ebf 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -1,6 +1,7 @@
 lvm_create
 lvm_destroy
-lvm_reload_config
+lvm_config_reload
+lvm_config_override
 lvm_pv_get_name
 lvm_pv_get_uuid
 lvm_pv_get_mda_count
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 0602e1b..7023419 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -149,6 +149,22 @@ void lvm_destroy(lvm_t libh);
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
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 3154846..33d8395 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -72,6 +72,14 @@ int lvm_config_reload(lvm_t libh)
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
-- 
1.6.0.6


