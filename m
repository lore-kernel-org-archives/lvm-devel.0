From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Dec 2018 19:12:34 -0500
Subject: master - cov: fix memleak on error path
Message-ID: <201812230012.wBN0CYkD005353@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc479b2b079735afce810d3d352e367216d5a931
Commit:        fc479b2b079735afce810d3d352e367216d5a931
Parent:        83c6f7e7e6e76199d836bf694266c78e3cbc12f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 22 23:37:04 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 22 23:55:48 2018 +0100

cov: fix memleak on error path

Do not leak lvs pointer on error path.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 993f2f5..7cbf92d 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1453,7 +1453,8 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		align_size = sanlock_align(&lms->ss.host_id_disk);
 		if (align_size <= 0) {
 			log_error("S %s prepare_lockspace_san align error %d", lsname, align_size);
-			return -EINVAL;
+			ret = -EINVAL;
+			goto fail;
 		}
 		sector_size = (align_size == ONE_MB) ? 512 : 4096;
 		log_debug("S %s prepare_lockspace_san found old sector_size %d align_size %d", lsname, sector_size, align_size);


