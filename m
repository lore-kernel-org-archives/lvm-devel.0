From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:21:08 +0000 (UTC)
Subject: master - config: separate cfg_def_default_value_hint out of cfg_def_get_default_value
Message-ID: <20140306112108.3862F6114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=932e75e89fcbce3c41a1875a707df5fd7ecdc5e6
Commit:        932e75e89fcbce3c41a1875a707df5fd7ecdc5e6
Parent:        eecf191d3e95526c6638c668a20472c9c3620967
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 4 10:29:08 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:18:19 2014 +0100

config: separate cfg_def_default_value_hint out of cfg_def_get_default_value

If the config setting is defined as having no default value, but it's
still not NULL, it means such a value acts as a *hint* only
(e.g. a starting value from which the default value is calculated).

The new "cfg_def_get_default_value_hint" will always return the value
as defined in config_settings.h.

The original "cfg_def_get_default_value" will always return 0/NULL if
the config setting is defined with CFG_DEFAULT_UNDEFINED flag (hence
ignoring the hint).

This is needed for proper distiction between a correct default value
and the value which is just a hint or a starting point in calculation,
but it's not the final value (yes, we do have such settings!).
---
 lib/config/config.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index a7cb5b2..b8c67d0 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -478,8 +478,8 @@ time_t config_file_timestamp(struct dm_config_tree *cft)
 }
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
-#define cfg_def_get_default_value(cmd,item,type,profile) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_value.fn_##type(cmd,profile) : item->default_value.v_##type)
-
+#define cfg_def_get_default_value_hint(cmd,item,type,profile) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_value.fn_##type(cmd,profile) : item->default_value.v_##type)
+#define cfg_def_get_default_value(cmd,item,type,profile) (item->flags & CFG_DEFAULT_UNDEFINED ? 0 : cfg_def_get_default_value_hint(cmd,item,type,profile))
 
 static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item, int xlate)
 {
@@ -1358,19 +1358,19 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 				break;
 			case CFG_TYPE_BOOL:
 				cn->v->type = DM_CFG_INT;
-				cn->v->v.i = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_BOOL, NULL);
+				cn->v->v.i = cfg_def_get_default_value_hint(spec->cmd, def, CFG_TYPE_BOOL, NULL);
 				break;
 			case CFG_TYPE_INT:
 				cn->v->type = DM_CFG_INT;
-				cn->v->v.i = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_INT, NULL);
+				cn->v->v.i = cfg_def_get_default_value_hint(spec->cmd, def, CFG_TYPE_INT, NULL);
 				break;
 			case CFG_TYPE_FLOAT:
 				cn->v->type = DM_CFG_FLOAT;
-				cn->v->v.f = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_FLOAT, NULL);
+				cn->v->v.f = cfg_def_get_default_value_hint(spec->cmd, def, CFG_TYPE_FLOAT, NULL);
 				break;
 			case CFG_TYPE_STRING:
 				cn->v->type = DM_CFG_STRING;
-				if (!(str = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_STRING, NULL)))
+				if (!(str = cfg_def_get_default_value_hint(spec->cmd, def, CFG_TYPE_STRING, NULL)))
 					str = "";
 				cn->v->v.str = str;
 				break;


