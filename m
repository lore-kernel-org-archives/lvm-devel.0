From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 Aug 2022 14:42:19 +0000 (GMT)
Subject: main - _vg_read_raw_area: fix segfault caused by using null pointer
Message-ID: <20220815144219.3AF5D3858404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce58e9d5b37c3e408f2b41c8095980490a87f2a4
Commit:        ce58e9d5b37c3e408f2b41c8095980490a87f2a4
Parent:        6b2e4ec5dc629c064a4f5472afd283faa233ca32
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Mon Aug 15 09:39:02 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 15 09:39:02 2022 -0500

_vg_read_raw_area: fix segfault caused by using null pointer

When we tested lvm2, the kernel injected various random faults.

(gdb) bt
...
(gdb) p vg
$1 = (struct volume_group *) 0x0
(gdb) p use_previous_vg
$2 = (unsigned int *) 0x0

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 lib/format_text/format-text.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 07aaa0b28..c1ccdb031 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -428,7 +428,7 @@ static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
 				rlocn->checksum,
 				&when, &desc);
 
-	if (!vg && !*use_previous_vg) {
+	if (!vg && (!use_previous_vg || !*use_previous_vg)) {
 		log_warn("WARNING: Failed to read metadata text at %llu off %llu size %llu VG %s on %s",
 			 (unsigned long long)(area->start + rlocn->offset),
 			 (unsigned long long)rlocn->offset,

