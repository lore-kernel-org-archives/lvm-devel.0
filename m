From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:18 +0000 (UTC)
Subject: master - cleanup: do not return stack content
Message-ID: <20130722104218.53F1160DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dedec81d7b939650f390c0be5a23632b39d83012
Commit:        dedec81d7b939650f390c0be5a23632b39d83012
Parent:        aed4e9c703a81aec0a56dc7134ff336683ab5c1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 17:29:37 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

cleanup: do not return stack content

Return initialized struct in error path.
---
 liblvm/lvm_lv.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index f416195..7fc2392 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -593,15 +593,16 @@ struct lvm_property_value lvm_lv_params_get_property(
 						const lv_create_params_t params,
 						const char *name)
 {
-	struct lvm_property_value rc;
-
-	rc.is_valid = 0;
+	struct lvm_property_value rc = {
+		.is_valid = 0
+	};
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
 		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, name);
 	} else {
 		log_error("Invalid lv_create_params parameter");
 	}
+
 	return rc;
 }
 


