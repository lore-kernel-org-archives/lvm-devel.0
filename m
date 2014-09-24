From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:15 +0000 (UTC)
Subject: master - cleanup: replace error with print message
Message-ID: <20140924085715.27491613A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=914be0696daf3603b6db055b2afe146190e9a7f7
Commit:        914be0696daf3603b6db055b2afe146190e9a7f7
Parent:        bc0a3e23553f8d622a7218ded55ac1fdaa75286c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 20 22:05:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

cleanup: replace error with print message

These are not error messages.
They are informing a user about missconfigured
options which do not change resulting error status.
---
 lib/activate/activate.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2a94ea6..4e1ec5f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -125,24 +125,23 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logic
 		if (cv->type == DM_CFG_EMPTY_ARRAY)
 			goto out;
 		if (cv->type != DM_CFG_STRING) {
-			log_error("Ignoring invalid string in config file %s",
-				  config_path);
+			log_print_unless_silent("Ignoring invalid string in config file %s.",
+						config_path);
 			continue;
 		}
 		str = cv->v.str;
 		if (!*str) {
-			log_error("Ignoring empty string in config file %s",
-				  config_path);
+			log_print_unless_silent("Ignoring empty string in config file %s.",
+						config_path);
 			continue;
 		}
 
-
 		/* Tag? */
 		if (*str == '@') {
 			str++;
 			if (!*str) {
-				log_error("Ignoring empty tag in config file "
-					  "%s", config_path);
+				log_print_unless_silent("Ignoring empty tag in config file %s",
+							config_path);
 				continue;
 			}
 			/* If any host tag matches any LV or VG tag, activate */


