From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 03:16:41 +0000 (UTC)
Subject: master - tools: Also recognise segtype with thin and cache.
Message-ID: <20160730031641.ED51460DA9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52d2fa7022c48791d003554e5e656a94c5970af8
Commit:        52d2fa7022c48791d003554e5e656a94c5970af8
Parent:        d1ff254c3cca0eed959095aa02ef9bfe36481065
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 04:12:58 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 04:12:58 2016 +0100

tools: Also recognise segtype with thin and cache.

(--type thin still needs this for lvcreate - more logic should be
shared between lvcreate and lvconvert)
---
 lib/metadata/segtype.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2fc7a12..bf7c5eb 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -133,6 +133,8 @@ struct dev_manager;
 
 #define segtype_supports_stripe_size(segtype)	\
 	((segtype_is_striped(segtype) || segtype_is_mirror(segtype) || \
+	  segtype_is_cache(segtype) || segtype_is_cache_pool(segtype) || \
+	  segtype_is_thin(segtype) || segtype_is_snapshot(segtype) || \
 	  (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))) ? 1 : 0)
 
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)


