From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:23 +0000 (UTC)
Subject: master - lvm2app: access params after its checked
Message-ID: <20140211180123.87FFD60D1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1faa4048a7421c14456cb1761548f7907bfbf53
Commit:        c1faa4048a7421c14456cb1761548f7907bfbf53
Parent:        38e457c4788d0d2e51bf46edbd82b4683d33ac8f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 9 21:36:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 18:50:37 2014 +0100

lvm2app: access params after its checked

Since params is checked for NULL, move code that dereferences
params after its check.
---
 liblvm/lvm_lv.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 9f3a9c6..d89e8ae 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -757,17 +757,15 @@ struct lvm_property_value lvm_lv_params_get_property(
 						const lv_create_params_t params,
 						const char *name)
 {
-	struct lvm_property_value rc = {
-		.is_valid = 0
-	};
-	struct saved_env e = store_user_env(params->vg->cmd);
+	struct lvm_property_value rc = { .is_valid = 0 };
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+		struct saved_env e = store_user_env(params->vg->cmd);
 		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, NULL, name);
-	} else {
+		restore_user_env(&e);
+	} else
 		log_error("Invalid lv_create_params parameter");
-	}
-	restore_user_env(&e);
+
 	return rc;
 }
 
@@ -775,15 +773,14 @@ int lvm_lv_params_set_property(lv_create_params_t params, const char *name,
 								struct lvm_property_value *prop)
 {
 	int rc = -1;
-	struct saved_env e = store_user_env(params->vg->cmd);
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+		struct saved_env e = store_user_env(params->vg->cmd);
 		rc = set_property(NULL, NULL, NULL, &params->lvp, NULL, name, prop);
-	} else {
+		restore_user_env(&e);
+	} else
 		log_error("Invalid lv_create_params parameter");
-	}
 
-	restore_user_env(&e);
 	return rc;
 }
 


