From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 23 Apr 2015 15:21:10 +0000 (UTC)
Subject: master - config: thin_disabled_features default should be undefined
Message-ID: <20150423152111.05ABC6006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8bdfbe959a641da21d3baf27046deb8d2eaddb2
Commit:        a8bdfbe959a641da21d3baf27046deb8d2eaddb2
Parent:        3fc9615d156892efd8bb28b0306c2fe9c14738ff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 23 10:19:00 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 23 10:19:00 2015 -0500

config: thin_disabled_features default should be undefined

An array that's empty by default should be flagged as
undefined.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1a0ebf7..6db9cda 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -823,7 +823,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL,
 	"String of options passed to the thin_repair command.\n")
 
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL,
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL,
 	"Features to not use in the thin driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"


