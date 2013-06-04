From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:09 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: drop zeroing of zallocated data
Message-ID: <20130604192509.DD21E60D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35ab841ecff4a887e70b54b1afb01dd42a4e9cd6
Commit:        35ab841ecff4a887e70b54b1afb01dd42a4e9cd6
Parent:        a12f92c494a60fe6e6c9e133aa879bd0d0da069a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 11:52:17 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 12:27:33 2013 +0200

cleanup: drop zeroing of zallocated data

---
 lib/config/config.c  |    2 --
 libdm/libdm-config.c |    4 +---
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 8acb87d..ad02f5f 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -67,8 +67,6 @@ struct dm_config_tree *config_file_open(const char *filename, int keep_open)
 	cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file));
 	if (!cf) goto fail;
 
-	cf->timestamp = 0;
-	cf->exists = 0;
 	cf->keep_open = keep_open;
 	dm_config_set_custom(cft, cf);
 
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 368f9e3..dfd9174 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -105,10 +105,8 @@ struct dm_config_tree *dm_config_create(void)
 		dm_pool_destroy(mem);
 		return 0;
 	}
-	cft->root = NULL;
-	cft->cascade = NULL;
-	cft->custom = NULL;
 	cft->mem = mem;
+
 	return cft;
 }
 


