From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:39 +0000 (GMT)
Subject: main - integrity: mark as user of secure_data
Message-ID: <20210302215839.600A7382E822@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b7a4503e51d29454bdb8852dfd2a39276f828af
Commit:        0b7a4503e51d29454bdb8852dfd2a39276f828af
Parent:        67790d7e3bcfb202eb42d23ab36dfdfe31713996
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 22:12:33 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

integrity: mark as user of secure_data

Use the secure_data with integrity target. Not so big difference,
as the secure feature of the integrity target is not used by lvm2.
---
 device_mapper/libdm-deptree.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index ec345ac55..7045e1f26 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2824,6 +2824,9 @@ static int _integrity_emit_segment_line(struct dm_task *dmt,
 	if (set->sectors_per_bit_set)
 		EMIT_PARAMS(pos, " sectors_per_bit:%llu", (unsigned long long)set->sectors_per_bit);
 
+	if (!dm_task_secure_data(dmt))
+		stack;
+
 	return 1;
 }
 


