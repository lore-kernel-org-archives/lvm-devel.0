From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  1 Oct 2015 19:43:14 +0000 (UTC)
Subject: master - config: improve cache_settings description
Message-ID: <20151001194314.297C260D77@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26da6a3e10d2b8a84326288b53c8e9a6d82a3846
Commit:        26da6a3e10d2b8a84326288b53c8e9a6d82a3846
Parent:        4c2cc782aa8c7e6bdc18339215f65e82ea1489ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 1 11:45:07 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 14:23:39 2015 -0500

config: improve cache_settings description

---
 lib/config/config_settings.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9017043..9cc444f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -474,8 +474,8 @@ cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PRO
 	"otherwise the older mq (Multiqueue) policy is selected.\n")
 
 cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
-	"Individual settings for policies.\n"
-	"See the help for individual policies for more info.\n")
+	"Settings for the cache policy.\n"
+	"See documentation for individual cache policies for more info.\n")
 
 cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_settings_CFG_SECTION, CFG_NAME_VARIABLE | CFG_SECTION_NO_CHECK | CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
 	"Replace this subsection name with a policy name.\n"


