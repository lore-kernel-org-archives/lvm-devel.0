From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:48 +0000 (UTC)
Subject: master - cleanup: just easier word wrapping
Message-ID: <20140815130748.934E160CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f183995f8ead0bf63aea6ce7983871015dc3efff
Commit:        f183995f8ead0bf63aea6ce7983871015dc3efff
Parent:        1bde4c19e65a823c9dc3a34606f2aefb76e41230
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 14 11:11:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

cleanup: just easier word wrapping

---
 man/lvconvert.8.in |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 93fb9a9..b8951e2 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -100,7 +100,8 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RI [ PhysicalVolume [ Path ]...]
 .sp
 .B lvconvert
-.RB [{ \-\-type \  \fIthin [ \fI\-pool ]| \-T | \-\-thin }
+.RB [{ \-\-type
+.BR \fIthin [ \fI\-pool ]| \-T | \-\-thin }
 .RB [ \-\-originname
 .IR NewExternalOriginVolumeName ]]
 .RB [ \-\-thinpool
@@ -131,7 +132,8 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-version ]
 .sp
 .B lvconvert
-.RB [ \-\-type \  \fIcache [ \fI\-pool ]| \-\-cache ]
+.RB [ \-\-type
+.BR \fIcache [ \fI\-pool ]| \-\-cache ]
 .RB [ \-\-cachepool
 .IR CachePoolLV { Name | Path }]
 .RB [ \-c | \-\-chunksize


