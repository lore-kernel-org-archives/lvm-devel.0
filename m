From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Oct 2012 13:37:42 +0000 (UTC)
Subject: master - cleanup: fix typo in error message
Message-ID: <20121019133742.BAB63A1046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc7d3b74f10bae4fd5931346f954601b89ddeee9
Commit:        bc7d3b74f10bae4fd5931346f954601b89ddeee9
Parent:        c7c53ad41d5521d5b431e799699c9ad6a07054a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 19 13:57:22 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 19 15:32:27 2012 +0200

cleanup: fix typo in error message

yes -> yet
---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 04facdd..842b2da 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -53,7 +53,7 @@ static int lvchange_permission(struct cmd_context *cmd,
 
 	if (!(lv_access & LVM_WRITE) && lv_is_thin_pool(lv)) {
 		log_error("Change permissions of thin pool \"%s\" not "
-			  "yes supported.", lv->name);
+			  "yet supported.", lv->name);
 		return 0;
 	}
 


