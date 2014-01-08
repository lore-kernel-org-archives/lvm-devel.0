From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jan 2014 11:05:44 +0000 (UTC)
Subject: master - liblvm: mark constant as unsigned
Message-ID: <20140108110544.A79396119F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f246bf768ae194fa19e71e596f99ca02547c55c
Commit:        5f246bf768ae194fa19e71e596f99ca02547c55c
Parent:        4417cd288b69479ade4f4ab98adfc4d5eb7f483b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 8 12:04:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 8 12:04:41 2014 +0100

liblvm: mark constant as unsigned

---
 liblvm/lvm_pv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 163ea4f..64b01d5 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -126,7 +126,7 @@ int lvm_pv_remove(lvm_t libh, const char *pv_name)
 	return rc;
 }
 
-#define PV_LIST_MAGIC 4026907153
+#define PV_LIST_MAGIC 4026907153U
 
 static struct dm_list *_lvm_list_pvs(lvm_t libh)
 {


