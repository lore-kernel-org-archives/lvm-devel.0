From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:13 +0000 (UTC)
Subject: master - cleanup: simplier _lv_passes_volumes_filter
Message-ID: <20140924085713.03A3E613A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc0a3e23553f8d622a7218ded55ac1fdaa75286c
Commit:        bc0a3e23553f8d622a7218ded55ac1fdaa75286c
Parent:        a1213401393ac6e6a9a9e168379574469eb715c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 01:08:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

cleanup: simplier _lv_passes_volumes_filter

Don't recreate string and just check components directly.
---
 lib/activate/activate.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3f9d1a2..2a94ea6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -114,7 +114,7 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logic
 	const struct dm_config_value *cv;
 	const char *str;
 	static char config_path[PATH_MAX];
-	static char path[PATH_MAX];
+	size_t len = strlen(lv->vg->name);
 
 	config_def_get_path(config_path, sizeof(config_path), cfg_id);
 	log_verbose("%s configuration setting defined: "
@@ -161,21 +161,12 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logic
 			else
 				continue;
 		}
-		if (!strchr(str, '/')) {
-			/* vgname supplied */
-			if (!strcmp(str, lv->vg->name))
-				return 1;
-			else
-				continue;
-		}
-		/* vgname/lvname */
-		if (dm_snprintf(path, sizeof(path), "%s/%s", lv->vg->name,
-				 lv->name) < 0) {
-			log_error("dm_snprintf error from %s/%s", lv->vg->name,
-				  lv->name);
-			continue;
-		}
-		if (!strcmp(path, str))
+
+		/* If supplied name is vgname[/lvname] */
+		if ((strncmp(str, lv->vg->name, len) == 0) &&
+		    (!str[len] ||
+		     ((str[len] == '/') &&
+		      !strcmp(str + len + 1, lv->name))))
 			return 1;
 	}
 


