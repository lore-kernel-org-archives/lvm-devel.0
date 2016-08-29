From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 29 Aug 2016 19:09:01 +0000 (UTC)
Subject: master - debug: better verbose message
Message-ID: <20160829190901.BAA7861080@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=784b46ef2a3b674def64a1185733122b300bb22c
Commit:        784b46ef2a3b674def64a1185733122b300bb22c
Parent:        92d5a8441007f578e000b492cecf67d6b8a87405
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 29 13:38:00 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 29 20:51:16 2016 +0200

debug: better verbose message

---
 lib/metadata/pool_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index f292a0c..a0fe11c 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -525,7 +525,7 @@ int update_pool_params(const struct segment_type *segtype,
 		return 0;
 	}
 
-	log_verbose("Using pool metadata size %s.",
+	log_verbose("Preferred pool metadata size %s.",
 		    display_size(vg->cmd, (uint64_t)*pool_metadata_extents * vg->extent_size));
 
 	return 1;


