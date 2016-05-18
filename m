From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 18 May 2016 14:07:00 +0000 (UTC)
Subject: master - lvm2_activation_generator: don't create full context for liblvm2app
Message-ID: <20160518140700.B2A6560F2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=591ef307b30c2d828b2a0c59918203f970974bbb
Commit:        591ef307b30c2d828b2a0c59918203f970974bbb
Parent:        7fd4119d24eee55323e888dd78c70257d7c97a15
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 17 12:03:25 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 18 09:05:26 2016 -0500

lvm2_activation_generator: don't create full context for liblvm2app

Don't use lvm_init() to create a full command context, which
does a lot of command setup (like connecting to daemons), which
is unnecessary for simply reading a value from lvm.conf.

Passing a NULL context arg to the lvm_config_ function is now
allowed, in which case lvm.conf is read without doing lvm
command setup.
---
 .../lvm2_activation_generator_systemd_red_hat.c    |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 62467bd..d83e721 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -69,16 +69,10 @@ static void kmsg(int log_level, const char *format, ...)
 
 static void lvm_get_use_lvmetad_and_lvmpolld(int *use_lvmetad, int *use_lvmpolld)
 {
-	lvm_t lvm;
-
 	*use_lvmetad = *use_lvmpolld = 0;
-	if (!(lvm = lvm_init(NULL))) {
-		kmsg(LOG_ERR, "LVM: Failed to initialize library context for activation generator.\n");
-		return;
-	}
-	*use_lvmetad = lvm_config_find_bool(lvm, LVM_CONF_USE_LVMETAD, 0);
-	*use_lvmpolld = lvm_config_find_bool(lvm, LVM_CONF_USE_LVMPOLLD, 0);
-	lvm_quit(lvm);
+
+	*use_lvmetad = lvm_config_find_bool(NULL, LVM_CONF_USE_LVMETAD, 0);
+	*use_lvmpolld = lvm_config_find_bool(NULL, LVM_CONF_USE_LVMPOLLD, 0);
 }
 
 static int register_unit_with_target(const char *dir, const char *unit, const char *target)


