From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:55 +0000 (UTC)
Subject: master - thin: improve lvconvert messages
Message-ID: <20140520195355.5A528603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16424fed543ee6d4841c1e44ba252ae976c28cbb
Commit:        16424fed543ee6d4841c1e44ba252ae976c28cbb
Parent:        d1d50d4023d7825fe9d9d3811375e44b90def529
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 20:05:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:29 2014 +0200

thin: improve lvconvert messages

Add more info into printed message.
---
 tools/lvconvert.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3f1fd46..79f2be5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2570,7 +2570,9 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 		goto deactivate_and_revert_new_lv;
 	}
 
-	log_print_unless_silent("Converted %s/%s to thin external origin.",
+	log_print_unless_silent("Converted \"%s/%s\" to thin volume with "
+				"external origin \"%s/%s\".",
+				vg->name, torigin_lv->name,
 				vg->name, external_lv->name);
 
 	return 1;
@@ -2954,7 +2956,7 @@ mda_write:
 		goto out;
 	}
 
-	log_print_unless_silent("Converted %s/%s to %s pool.",
+	log_print_unless_silent("Converted \"%s/%s\" to %s pool.",
 				pool_lv->vg->name, pool_lv->name,
 				(segtype_is_cache_pool(lp->segtype)) ?
 				"cache" : "thin");


