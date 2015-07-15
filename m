From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 15 Jul 2015 14:17:32 +0000 (UTC)
Subject: master - config: make a difference between "not found" and "is empty" in log msg for devices/preferred_names
Message-ID: <20150715141732.BCF5360D3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d947a815e8bc6080ee5b364bd55f8aa0c2807f4e
Commit:        d947a815e8bc6080ee5b364bd55f8aa0c2807f4e
Parent:        d10fb73f63649baec3cec28e1ee573c2ef6b95d6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 15 16:14:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 15 16:14:51 2015 +0200

config: make a difference between "not found" and "is empty" in log msg for devices/preferred_names

Replace misleading "not found" in the log message when
devices/preferred_names is set to empty array:

Really not found:
device/dev-cache.c:689   devices/preferred_names not found in config: using built-in preferences

Found, but empty:
config/config.c:1431   Setting devices/preferred_names to preferred_names = [ ]
device/dev-cache.c:689   devices/preferred_names is empty: using built-in preferences
---
 lib/device/dev-cache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 136921b..d854e2b 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -683,8 +683,10 @@ static int _init_preferred_names(struct cmd_context *cmd)
 
 	if (!(cn = find_config_tree_array(cmd, devices_preferred_names_CFG, NULL)) ||
 	    cn->v->type == DM_CFG_EMPTY_ARRAY) {
-		log_very_verbose("devices/preferred_names not found in config file: "
-				 "using built-in preferences");
+		log_very_verbose("devices/preferred_names %s: "
+				 "using built-in preferences",
+				 cn && cn->v->type == DM_CFG_EMPTY_ARRAY ? "is empty"
+									 : "not found in config");
 		return 1;
 	}
 


