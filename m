From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:44:50 -0400
Subject: stable-2.02 - cov: release iterator on error path
Message-ID: <201906251544.x5PFio93012462@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09aafb61e31c3781530795057c87afaeb53a2bd4
Commit:        09aafb61e31c3781530795057c87afaeb53a2bd4
Parent:        3b42cdad0c27d79766c7e9aae50d13cd93a2ffbf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:37:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:32:44 2019 +0200

cov: release iterator on error path

---
 lib/label/label.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 4f8e135..9a3f8df 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -866,8 +866,11 @@ int label_scan(struct cmd_context *cmd)
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(devl = dm_zalloc(sizeof(*devl))))
+		if (!(devl = dm_zalloc(sizeof(*devl)))) {
+			log_error("Failed to allocated device list.");
+			dev_iter_destroy(iter);
 			return 0;
+		}
 		devl->dev = dev;
 		dm_list_add(&all_devs, &devl->list);
 


