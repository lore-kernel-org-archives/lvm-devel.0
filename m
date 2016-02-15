From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 13:47:43 +0000 (UTC)
Subject: master - pv: mark fake PVs as not used
Message-ID: <20160215134743.AD01D6054A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0000db7f98a07aa31c5b1cf13938b612e7f2821b
Commit:        0000db7f98a07aa31c5b1cf13938b612e7f2821b
Parent:        abbaeef096251c4191e6da2518e646dd78b82da8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 15 14:46:31 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 14:46:31 2016 +0100

 pv: mark fake PVs as not used

Some of the PVs are not even orphan PVs - they're fake PVs - this can
happen if we're listing all devices with "pvs -a". Such PV must not
be marked as used.
---
 lib/metadata/pv.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 260eb9b..d5820b5 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -213,6 +213,9 @@ int is_used_pv(const struct physical_volume *pv)
 	struct lvmcache_info *info;
 	uint32_t ext_flags;
 
+	if (!pv->vg)
+		return 0;
+
 	if (!is_orphan(pv))
 		return 1;
 


