From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  4 Jul 2013 12:03:43 +0000 (UTC)
Subject: master - lvconvert: fix last commit
Message-ID: <20130704120343.6414B61017@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0ce432829d71da0c03647e249f4742cc98cea74
Commit:        a0ce432829d71da0c03647e249f4742cc98cea74
Parent:        969c87fa5b66859567a2d6de2b6700ee795d8e59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 4 14:02:27 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 4 14:02:27 2013 +0200

lvconvert: fix last commit

Condition needs to check for passed in pool_metadata_lv_name
which needs to be renamed to _tmeta, for !pool_metadata_lv_name
it's already created with correct _tmeta name.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fff0188..a0e6af7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2203,7 +2203,7 @@ mda_write:
 
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */
-	if (!lp->pool_metadata_lv_name &&
+	if (lp->pool_metadata_lv_name &&
 	    !lv_rename_update(cmd, metadata_lv, metadata_name, 0))
 		return_0;
 


