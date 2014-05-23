From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 19:38:50 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140523193850.5262261135@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a840323229555889184e831000b0c22f273ef66
Commit:        1a840323229555889184e831000b0c22f273ef66
Parent:        bf6b69c46b77f7b61c688b99b2bbaab0c46d840c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 14:25:12 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 21:37:12 2014 +0200

cleanup: indent

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5fa75e1..76a9103 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4310,7 +4310,7 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lp->poolmetadatasize &&
 	    !_lvresize_poolmetadata_prepare(cmd, lp, lv))
-			return_0;
+		return_0;
 
 	return 1;
 }


