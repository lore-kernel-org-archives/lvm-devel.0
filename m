From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:00:47 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: keep sp_count unsigned
Message-ID: <20130605120047.ACB6360D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4cce09dbdbf1fdb8e6ca985144fdeb181c3a480b
Commit:        4cce09dbdbf1fdb8e6ca985144fdeb181c3a480b
Parent:        719e908bc010455fc14589d941b949c5f3c92806
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 11 13:46:47 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 12 11:26:31 2013 +0200

lvmcache: keep sp_count unsigned

---
 lib/format_pool/disk_rep.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index c4afefe..899a48d 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -242,7 +242,7 @@ struct _read_pool_pv_baton {
 	struct dm_list *head;
 	const char *vgname;
 	uint32_t *sp_devs;
-	int sp_count;
+	uint32_t sp_count;
 	int failed;
 	int empty;
 };


