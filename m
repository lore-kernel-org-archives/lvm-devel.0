From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 28 Apr 2015 13:44:20 +0000 (UTC)
Subject: master - config: make it possible to set default unconfigured_value for settings of all types, not just strings
Message-ID: <20150428134420.5D7C460FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=afcf47246458a9b1ec37ab1b55348b615c58c81a
Commit:        afcf47246458a9b1ec37ab1b55348b615c58c81a
Parent:        de6deec3b8a981d8d1ebb7ada826d2e661735a30
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 28 13:50:23 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 28 15:32:38 2015 +0200

config: make it possible to set default unconfigured_value for settings of all types, not just strings

The @something@ used for unconfigured default value is not bound to
CFG_TYPE_STRING settings defined in config_settings.h, it can be
used for any other config type too.
---
 lib/config/config.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index bf1edcf..331bd00 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1675,7 +1675,10 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 
 	cn->id = def->id;
 
-	if (!(def->type & CFG_TYPE_ARRAY)) {
+	if (spec->unconfigured && def->unconfigured_value) {
+		cn->v->type = DM_CFG_STRING;
+		cn->v->v.str = def->unconfigured_value;
+	} else if (!(def->type & CFG_TYPE_ARRAY)) {
 		switch (def->type) {
 			case CFG_TYPE_SECTION:
 				cn->v = NULL;
@@ -1697,9 +1700,6 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 				if (!(str = cfg_def_get_default_value_hint(spec->cmd, def, CFG_TYPE_STRING, NULL)))
 					str = "";
 				cn->v->v.str = str;
-
-				if (spec->unconfigured && def->unconfigured_value)
-					cn->v->v.str = def->unconfigured_value;
 				break;
 			default:
 				log_error(INTERNAL_ERROR "_add_def_node: unknown type");


