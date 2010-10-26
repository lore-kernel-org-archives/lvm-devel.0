From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 14:59:24 +0200
Subject: [PATCH 3/5] Ensure first is not NULL before dereference
In-Reply-To: <cover.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
Message-ID: <f89a9f77dcb9846146ebbe014ac9958ce76c9b32.1288097372.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error Dereference of null pointer

For empty lists make sure the NULL first pointer is not dereferenced
and report error.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/format1.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 0dcec05..c5685c9 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -102,6 +102,11 @@ static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
 		pv_count++;
 	}
 
+	if (!first) {
+		log_error(INTERNAL_ERROR "Unexpected empty PV list.");
+		return 0;
+	}
+
 	/* On entry to fn, list known to be non-empty */
 	if (pv_count != first->vgd.pv_cur) {
 		log_error("%d PV(s) found for VG %s: expected %d",
-- 
1.7.3.2


