From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  2 Apr 2013 13:18:26 +0000 (UTC)
Subject: master - cleanup: indent line
Message-ID: <20130402131826.D8E60208D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=435e0bb60895b3831840a10a5deb68a51936f3e9
Commit:        435e0bb60895b3831840a10a5deb68a51936f3e9
Parent:        b57b394ebbb4b4078d532318110cff60e38035d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 27 11:49:10 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 2 15:17:05 2013 +0200

cleanup: indent line

---
 lib/metadata/segtype.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index d3ad2b2..1a23658 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -47,7 +47,7 @@ struct dev_manager;
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
-#define     seg_is_linear(seg)  (seg_is_striped(seg) && ((seg)->area_count == 1))
+#define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)


