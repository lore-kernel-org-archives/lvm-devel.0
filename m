From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:44:01 +0000 (GMT)
Subject: main - gcc: drop unused assingment
Message-ID: <20210210144401.9EF89385DC33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04cd4df847c682a65fa4c451d78b76a052d1155d
Commit:        04cd4df847c682a65fa4c451d78b76a052d1155d
Parent:        a1e2541333ed551c41882e2a636a1ab981d425b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 14:55:35 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

gcc: drop unused assingment

---
 lib/config/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index f9ca56677..96f2ad58d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -710,7 +710,7 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 		return array;
 	}
 
-	if (!(p = token = enc_value = strdup(def_enc_value))) {
+	if (!(token = enc_value = strdup(def_enc_value))) {
 		log_error("_get_def_array_values: strdup failed");
 		return NULL;
 	}


