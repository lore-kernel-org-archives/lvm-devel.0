From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Jun 2016 13:59:39 +0000 (UTC)
Subject: master - libdm: do not issue 'Failed to create directory' message for failure in dm_create_dir
Message-ID: <20160629135939.C5AAD61658@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eac0706761e628532ffcd27f3e4d7fa559a5f818
Commit:        eac0706761e628532ffcd27f3e4d7fa559a5f818
Parent:        686acce23fed6bd72af63201e4cc56bc5958379e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 29 15:58:14 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 29 15:58:18 2016 +0200

libdm: do not issue 'Failed to create directory' message for failure in dm_create_dir

There are detailed messages inside _create_dir_recursive that
dm_create_dir calls (except EROFS which where the message is not
generated, like anywhere else in the code).
---
 libdm/libdm-file.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 9867824..2c313b3 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -97,10 +97,8 @@ int dm_create_dir(const char *dir)
 	if (stat(dir, &info) == 0 && S_ISDIR(info.st_mode))
 		return 1;
 
-	if (!_create_dir_recursive(dir)) {
-		log_error("Failed to create directory %s.", dir);
-		return 0;
-	}
+	if (!_create_dir_recursive(dir))
+		return_0;
 
 	return 1;
 }


