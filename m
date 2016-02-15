From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 14:53:24 +0000 (UTC)
Subject: master - pv: use pv->fmt to check for fake PVs, not pv->vg
Message-ID: <20160215145324.58F3360B3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45be3c875f4605f4f950e8abfa12cf422526f5db
Commit:        45be3c875f4605f4f950e8abfa12cf422526f5db
Parent:        099d99975c25ba4f4c0593b778c95e7e185fd527
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 15 15:50:11 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 15:52:13 2016 +0100

pv: use pv->fmt to check for fake PVs, not pv->vg

pv->vg is not set yet during pvcreate processing. Use pv->fmt instead to
check for these fake PVs (all normal PVs have format defined, devices
which are not PVs don't have this set).

This fixes commit 0000db7f98a07aa31c5b1cf13938b612e7f2821b.
---
 lib/metadata/pv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index d5820b5..1d68045 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -213,7 +213,7 @@ int is_used_pv(const struct physical_volume *pv)
 	struct lvmcache_info *info;
 	uint32_t ext_flags;
 
-	if (!pv->vg)
+	if (!pv->fmt)
 		return 0;
 
 	if (!is_orphan(pv))


