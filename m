From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  5 Jul 2013 01:00:54 +0000 (UTC)
Subject: master - locking: fix cluster lock_resource fn prototype
Message-ID: <20130705010054.7245961514@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21bc118d4db22259d45aef32aa77f78621ddf8c1
Commit:        21bc118d4db22259d45aef32aa77f78621ddf8c1
Parent:        1cb66fe16e0bc180a0be8e18d8b361b5b5842128
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 5 01:59:52 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 5 01:59:52 2013 +0100

locking: fix cluster lock_resource fn prototype

---
 lib/locking/cluster_locking.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 89d7307..7cbb8f1 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -33,7 +33,7 @@
 #include <unistd.h>
 
 #ifndef CLUSTER_LOCKING_INTERNAL
-int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags);
+int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, struct logical_volume *lv __attribute__((unused)));
 int query_resource(const char *resource, int *mode);
 void locking_end(void);
 int locking_init(int type, struct dm_config_tree *cf, uint32_t *flags);


