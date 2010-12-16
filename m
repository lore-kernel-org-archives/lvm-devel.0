From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:28 +0100
Subject: [PATCH 20/20] Add internal error if pointer is uninitialized
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <97610b28639fffe58661808135827259da41bd7f.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add simple check for existance of 'pl'.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_pool/disk_rep.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 2c16f50..ca8bfd7 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -263,6 +263,11 @@ static int _read_vg_pds(const struct format_type *fmt, struct dm_pool *mem,
 		 */
 		if (!sp_count) {
 			/* FIXME pl left uninitialised if !info->dev */
+			if (!pl) {
+				log_error(INTERNAL_ERROR "device is missing");
+				dm_pool_destroy(tmpmem);
+				return 0;
+			}
 			sp_count = pl->pd.pl_subpools;
 			if (!(sp_devs =
 			      dm_pool_zalloc(tmpmem,
-- 
1.7.3.3


