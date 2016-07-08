From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 Jul 2016 19:34:44 +0000 (UTC)
Subject: master - lvconvert: allow splitcache on hidden/used cache pool
Message-ID: <20160708193444.D83FA60FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3951ca93204742d23b56f8d253230d33f322aad5
Commit:        3951ca93204742d23b56f8d253230d33f322aad5
Parent:        39921284a03fd2d2c3f3ac22c3e69cba913494bf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 8 14:08:55 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 8 14:34:36 2016 -0500

lvconvert: allow splitcache on hidden/used cache pool

lvconvert --splitcache VG/CachePool_corig

Allow the split via the hidden/used cache pool for the time being,
since the new lvconvert code did intend to allow it, but was just
missing the exception in the list of hidden LVs that were allowed.

The preferred method for splitcache is to run it on the visible
cache LV, not the hidden cache pool.  That may eventually become
the only method since we try to avoid running commands on
hidden LVs.
---
 tools/lvconvert.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0009270..0319601 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4372,6 +4372,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		    !lv_is_cache_pool_data(lv) &&
 		    !lv_is_thin_pool_metadata(lv) &&
 		    !lv_is_thin_pool_data(lv) &&
+		    !lv_is_used_cache_pool(lv) &&
 		    !lv_is_raid_image(lv)) {
 			log_error("Cannot convert internal LV %s.", display_lvname(lv));
 			ret = 0;


