From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 24 Feb 2014 16:21:21 +0000 (UTC)
Subject: master - cache: Disallow resizing of cache related LVs
Message-ID: <20140224162121.59B1B61009@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3d1debb18cc58d36eed75ba6610e5a3ef498d12
Commit:        f3d1debb18cc58d36eed75ba6610e5a3ef498d12
Parent:        46223c4284552b23cac7c49c49dc1612b45bb66e
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Feb 24 10:19:50 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Feb 24 10:19:50 2014 -0600

cache: Disallow resizing of cache related LVs

For now, disallow lvextend/lvreduce/lvresize of cache LVs, cache
pool LVs, and cache pool sub-LVs.
---
 lib/metadata/lv_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e25dd17..92e65ae 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4274,6 +4274,11 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	struct logical_volume *lock_lv = NULL;
 	int inactive = 0;
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Unable to resize logical volumes of cache type.");
+		return 0;
+	}
+
 	if (lp->sizeargs &&
 	    !(lock_lv = _lvresize_volume(cmd, lv, lp, pvh)))
 		return_0;


