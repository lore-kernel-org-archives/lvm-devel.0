From: corubba <corubba@gmx.de>
Date: Tue, 11 Oct 2022 22:06:26 +0200
Subject: [PATCH] locking: Fix sanlock lvmlock lv size calculation
Message-ID: <93cafad1-cfed-c13d-34b9-aa7ddd42d1e0@gmx.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The number of extents for the sanlock lvmlock lv is calculated using
integer division, which rounds towards zero. With a physical extent size
of 129M, instead of the requested 256M the lv is only 129M (1 extent).
With any physical extent size greater than 256M the lv creation fails
because the number of extents is zero.

This is fixed by replacing the integer division with a division macro
that rounds up and thus guarantees that the size of the lv will always
be equal or greater than the requested size. Using the examples above, a
pes of 129M will result in a 258M lv (2 extents), pes of 300M in a 300M
lv (1 extent).

The re-calculation of the lv size in bytes and megabytes is only so the
debug output shows the correct values. The size in mb there is still
not byte-perfect-accurate, but good enough for a human-readable estimate;
and the exact size in bytes and extents is right next to it.

Signed-off-by: corubba <corubba@gmx.de>
---
  lib/locking/lvmlockd.c | 4 +++-
  1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 2ef0900d4..7f8150365 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -513,9 +513,11 @@ static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,

  	lv_size_bytes = num_mb * ONE_MB_IN_BYTES;  /* size of sanlock LV in bytes */
  	extent_bytes = vg->extent_size * SECTOR_SIZE; /* size of one extent in bytes */
-	total_extents = lv_size_bytes / extent_bytes; /* number of extents in sanlock LV */
+	total_extents = dm_div_up(lv_size_bytes, extent_bytes); /* number of extents in sanlock LV */
  	lp.extents = total_extents;

+	lv_size_bytes = total_extents * extent_bytes;
+	num_mb = lv_size_bytes / ONE_MB_IN_BYTES;
  	log_debug("Creating lvmlock LV for sanlock with size %um %ub %u extents", num_mb, lv_size_bytes, lp.extents);

  	dm_list_init(&lp.tags);
--
2.38.0

