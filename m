From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Jul 2013 11:50:24 +0000 (UTC)
Subject: master - config: fix unterminated strings in arrays
Message-ID: <20130709115024.6C89560D14@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=618d13705c233b8ab7290653228b17ee111479f4
Commit:        618d13705c233b8ab7290653228b17ee111479f4
Parent:        aaa9a68b2fc8a25377f4649b89b59a9893179633
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 9 13:41:44 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 9 13:49:58 2013 +0200

config: fix unterminated strings in arrays

...when creating config trees while calling config_def_create_tree fn
that constructs a tree out of config_settings.h definition
(CFG_DEF_TREE_NEW/MISSING/DEFAULT/PROFILABLE).
---
 lib/config/config.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index e18e623..7e79dd7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1251,13 +1251,12 @@ static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
 				v->type = DM_CFG_FLOAT;
 				break;
 			case 'S':
-				if (!(r = dm_pool_alloc(cft->mem, strlen(token + 1)))) {
+				if (!(r = dm_pool_strdup(cft->mem, token + 1))) {
 					dm_free(enc_value);
 					log_error("Failed to duplicate token for default "
 						  "array value of %s.", def->name);
 					return NULL;
 				}
-				memcpy(r, token + 1, strlen(token + 1));
 				v->v.str = r;
 				v->type = DM_CFG_STRING;
 				break;


