From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 02:53:22 +0000 (UTC)
Subject: master - tools: mirror also supports stripesize
Message-ID: <20160730025322.50A3E606D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1ff254c3cca0eed959095aa02ef9bfe36481065
Commit:        d1ff254c3cca0eed959095aa02ef9bfe36481065
Parent:        b3fbcd1ff7cae307b2796fe0df9ef32655f6f87a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 03:52:49 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 03:52:49 2016 +0100

tools: mirror also supports stripesize

---
 lib/metadata/segtype.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index f39007f..2fc7a12 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -132,7 +132,8 @@ struct dev_manager;
 #define segtype_is_unknown(segtype)	((segtype)->flags & SEG_UNKNOWN ? 1 : 0)
 
 #define segtype_supports_stripe_size(segtype)	\
-	((segtype_is_striped(segtype) || (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))) ? 1 : 0)
+	((segtype_is_striped(segtype) || segtype_is_mirror(segtype) || \
+	  (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))) ? 1 : 0)
 
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)


