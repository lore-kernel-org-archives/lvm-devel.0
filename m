From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:23:01 +0000 (UTC)
Subject: master - cleanup: fix typos
Message-ID: <20121010192301.14064AB3C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6512b10ae258b2d7e9b2cb6c5fff2edb2042c96
Commit:        b6512b10ae258b2d7e9b2cb6c5fff2edb2042c96
Parent:        ca09c9ab4c082c1b3291748630a0133fb5f8f780
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 9 19:42:26 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 21:22:11 2012 +0200

cleanup: fix typos

---
 lib/metadata/thin_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index c1fa8b2..e7e96df 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -350,7 +350,7 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 			return 0;
 		}
 	} else {
-		log_warn("WARNING: Pool %s is created without initilization.", pool_lv->name);
+		log_warn("WARNING: Pool %s is created without initialization.", pool_lv->name);
 	}
 
 	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
@@ -456,7 +456,7 @@ const char *get_pool_discards_name(thin_discards_t discards)
 		return "ignore";
 	}
 
-	log_error(INTERNAL_ERROR "Uknown discards type encountered.");
+	log_error(INTERNAL_ERROR "Unknown discards type encountered.");
 
 	return "unknown";
 }


