From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:41 +0000 (UTC)
Subject: master - config: use proper unconfigured default values for use_lvmetad and use_lvmpolld settings
Message-ID: <20150624092741.7896560FB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74bf75a2f5f7b918e1fe7531766aa377de23191c
Commit:        74bf75a2f5f7b918e1fe7531766aa377de23191c
Parent:        1545ebf938d3eab5df5ab48b8258afc4f62b896b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 14:13:12 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:13:38 2015 +0200

config: use proper unconfigured default values for use_lvmetad and use_lvmpolld settings

Default value for lvmetad and lvmpolld has hooks in configure script,
the "lvmconfig --type default --unconfigured" should display:

   use_lvmetad = @DEFAULT_USE_LVMETAD@
   use_lvmpolld = @DEFAULT_USE_LVMPOLLD@

Note that these settings are not of string type. Recent change (the
DM_CONFIG_VALUE_FMT_STRING_NO_QUOTES formatting flag) makes it
possible to recognize that the setting is not of string type and if
there's unconfigured value defined for it, the enclosing " " is
automatically removed on output.
---
 lib/config/config_settings.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9335a7a..1b67488 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -797,7 +797,7 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"was never a valid path in the /dev filesystem.\n"
 	"Enable this option to reinstate the previous format.\n")
 
-cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), NULL, 0, NULL,
+cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), "@DEFAULT_USE_LVMETAD@", 0, NULL,
 	"Use lvmetad to cache metadata and reduce disk scanning.\n"
 	"When enabled (and running), lvmetad provides LVM commands\n"
 	"with VG metadata and PV state.  LVM commands then avoid\n"
@@ -937,7 +937,7 @@ cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"Some of the checks may be expensive, so it's best to use\n"
 	"this only when there seems to be a problem.\n")
 
-cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), NULL, 0, NULL,
+cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), "@DEFAULT_USE_LVMPOLLD@", 0, NULL,
 	"Use lvmpolld to supervise long running LVM commands.\n"
 	"When enabled, control of long running LVM commands is transferred\n"
 	"from the original LVM command to the lvmpolld daemon.  This allows\n"


