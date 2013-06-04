From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:14 +0000 (UTC)
Subject: dev-mornfall-activate - thin: limited support for -l%FREE allocation
Message-ID: <20130604192614.A01B661084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fc67f5509fda25a91536fbeeb7099f8327ff3d8
Commit:        6fc67f5509fda25a91536fbeeb7099f8327ff3d8
Parent:        55fe07ad98315d9471a86affd0680749e349a0a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 13 13:03:04 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 13 13:13:22 2013 +0200

thin: limited support for -l%FREE allocation

This is just a temporary fix to support allocation of -l%FREE.

The number of free extent serves to calculate estimated metadata
size. This value is then substracted twice to keep some
free space for recover.
---
 tools/lvcreate.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index df05cbb..7580155 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -321,6 +321,14 @@ static int _update_extents_params(struct volume_group *vg,
 		if (!(lp->poolmetadataextents =
 		      extents_from_size(vg->cmd, lp->poolmetadatasize, vg->extent_size)))
 			return_0;
+		if (lcp->percent == PERCENT_FREE) {
+			if (lp->extents <= (2 * lp->poolmetadataextents)) {
+				log_error("Not enough space for thin pool creation.");
+				return 0;
+			}
+			/* FIXME: persistent hidden space in VG wanted */
+			lp->extents -= (2 * lp->poolmetadataextents);
+		}
 	}
 
 	return 1;


