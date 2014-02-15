From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Feb 2014 10:38:57 +0000 (UTC)
Subject: master - libdm: use 64bit type for raid index
Message-ID: <20140215103857.218F460E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ec8e691c40e0b42a328366e3201cf4264108434
Commit:        7ec8e691c40e0b42a328366e3201cf4264108434
Parent:        f0f4248333a6dfa017d84dfd7bb298a3321a6ec2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 14 21:13:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 15 11:36:37 2014 +0100

libdm: use 64bit type for raid index

Used properly signed 64bit constant for shifting.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 827e994..3d7c734 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Use correctly signed 64b constant when working with raid volumes.
   Exit dmeventd with pidfile cleanup instead of raising SIGKILL on DIE request.
   Add new DM_EVENT_GET_PARAMETERS request to dmeventd protocol.
   Do not use systemd's reload for dmeventd restart, use dmeventd -R instead.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 32d53be..72c30a2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2243,11 +2243,11 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
 
 	for (i = 0; i < (seg->area_count / 2); i++)
-		if (seg->rebuilds & (1 << i))
+		if (seg->rebuilds & (1ULL << i))
 			EMIT_PARAMS(pos, " rebuild %u", i);
 
 	for (i = 0; i < (seg->area_count / 2); i++)
-		if (seg->writemostly & (1 << i))
+		if (seg->writemostly & (1ULL << i))
 			EMIT_PARAMS(pos, " write_mostly %u", i);
 
 	if (seg->writebehind)


