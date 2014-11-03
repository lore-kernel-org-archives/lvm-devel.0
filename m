From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:51 +0000 (UTC)
Subject: master - cache: wipe cache-pool before reuse
Message-ID: <20141103132351.1611960243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7bc28b7b7dfdcaf6be9f3d8050994d2df35d3e9
Commit:        b7bc28b7b7dfdcaf6be9f3d8050994d2df35d3e9
Parent:        29bd3cccc8de8949754edfe3d5a4c490627d5fa5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 19:41:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: wipe cache-pool before reuse

Before we reuse cache-pool - we need to ensure metadata volume
has wiped header.
---
 lib/metadata/lv_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a42a7f5..b5fc84a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6678,6 +6678,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				lp->extents = size;
 			}
 		}
+
+		if (seg_is_cache(lp) &&
+		    !wipe_cache_pool(pool_lv))
+			return_NULL;
 	}
 
 	/* Resolve origin volume */


