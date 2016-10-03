From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  3 Oct 2016 13:54:41 +0000 (UTC)
Subject: master - libdm: free FIEMAP buffer before returning
Message-ID: <20161003135441.E85076132B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5aaedfd0eed81bb6ef817dbe0e6a3937aa27ba6
Commit:        e5aaedfd0eed81bb6ef817dbe0e6a3937aa27ba6
Parent:        ca00a4d4e1c9b9742918e478b1f71310001b91fa
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Oct 3 14:54:17 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Oct 3 14:54:17 2016 +0100

libdm: free FIEMAP buffer before returning

---
 libdm/libdm-stats.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index dc30051..77e94a1 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4286,7 +4286,13 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 
 	/* return total number of extents */
 	*count = tot_extents;
-	return dm_pool_end_object(mem);
+
+	/* end the extents table before freeing the FIEMAP buffer */
+	extents = dm_pool_end_object(mem);
+
+	dm_pool_free(mem, buf);
+	return extents;
+
 bad:
 	dm_pool_abandon_object(mem);
 	dm_pool_free(mem, buf);


