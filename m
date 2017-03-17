From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 17 Mar 2017 09:22:53 -0400
Subject: master - lvm2app: correct internal API changes
Message-ID: <201703171322.v2HDMr3F012185@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d211c98581ee0ce9d1a919d64fd4d0df157c3069
Commit:        d211c98581ee0ce9d1a919d64fd4d0df157c3069
Parent:        e0ea56904515e4c1a75256f4327d414b0d2506cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 17 14:00:18 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 17 14:22:33 2017 +0100

lvm2app: correct internal API changes

Internal library gets more strict about setting discard and
zero_new_blocks parameter.
---
 liblvm/lvm_lv.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 05dd482..d5ca821 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -566,7 +566,21 @@ static lv_create_params_t _lvm_lv_params_create_thin_pool(vg_t vg,
 
 	if (lvcp) {
 		lvcp->vg = vg;
-		lvcp->lvp.discards = (thin_discards_t) discard;
+		switch (discard) {
+		case LVM_THIN_DISCARDS_IGNORE:
+			lvcp->lvp.discards = THIN_DISCARDS_IGNORE;
+			break;
+		case LVM_THIN_DISCARDS_NO_PASSDOWN:
+			lvcp->lvp.discards = THIN_DISCARDS_NO_PASSDOWN;
+			break;
+		case LVM_THIN_DISCARDS_PASSDOWN:
+			lvcp->lvp.discards = THIN_DISCARDS_PASSDOWN;
+			break;
+		default:
+			log_error("Invalid discard argument %d for thin pool creation.", discard);
+			return NULL;
+		}
+		lvcp->lvp.zero_new_blocks = THIN_ZERO_YES;
 
 		if (chunk_size)
 			lvcp->lvp.chunk_size = chunk_size;


