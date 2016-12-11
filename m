From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:35:00 +0000 (UTC)
Subject: master - cov: declaration matching
Message-ID: <20161211223500.2192E6038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a33e4c509fb72bf3540d20bd35e1f0944e1d37a
Commit:        4a33e4c509fb72bf3540d20bd35e1f0944e1d37a
Parent:        b8c729efd094146437c3ed5b336b929608401535
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 9 23:10:00 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

cov: declaration matching

---
 lib/format_text/format-text.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index bfabdfd..d6e6b03 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -59,7 +59,7 @@ int add_da(struct dm_pool *mem, struct dm_list *das,
 void del_das(struct dm_list *das);
 int add_ba(struct dm_pool *mem, struct dm_list *eas,
 	   uint64_t start, uint64_t size);
-void del_bas(struct dm_list *eas);
+void del_bas(struct dm_list *bas);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);


