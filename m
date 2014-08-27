From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 27 Aug 2014 12:31:55 +0000 (UTC)
Subject: master - cache: Clean-up error message.
Message-ID: <20140827123155.66CB460DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b9eb95ea9d2a950286f622f6d2d571c76642654
Commit:        8b9eb95ea9d2a950286f622f6d2d571c76642654
Parent:        dd9700f1925dbe20e657765400a80b62a9d0adb3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Sun Aug 24 19:44:37 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Sun Aug 24 19:44:37 2014 -0500

cache: Clean-up error message.

It is not an internal error message to report to the user that they
cannot create a cache LV on top of a cache LV.  It is simply not
supported yet.
---
 lib/metadata/cache_manip.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index f617f4e..04e165f 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -117,9 +117,8 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 		 * The origin under the origin would become *_corig_corig
 		 * before renaming the origin above to *_corig.
 		 */
-		log_error(INTERNAL_ERROR
-			  "The origin, %s, cannot be of cache type",
-			  origin->name);
+		log_error("Creating a cache LV from an existing cache LV is"
+			  "not yet supported.");
 		return NULL;
 	}
 


