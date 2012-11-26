From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Nov 2012 11:17:16 +0000 (UTC)
Subject: master - lvm2api: fix typo
Message-ID: <20121126111716.6F6BCA0DA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=668b669d5b40cb4a2d2ed62ebacb02ebeab03b98
Commit:        668b669d5b40cb4a2d2ed62ebacb02ebeab03b98
Parent:        60668f823e830ce39e452234996910c51728aa76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 21 14:29:52 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 26 11:33:24 2012 +0100

lvm2api: fix typo

oops, typo didn't cause compile error
---
 liblvm/lvm_lv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 77bdebf..b2a604d 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -146,7 +146,7 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 {
 	struct lvcreate_params lp = { 0 };
 	uint64_t extents;
-	struct logival_volume *lv;
+	struct logical_volume *lv;
 
 	if (vg_read_error(vg))
 		return NULL;


