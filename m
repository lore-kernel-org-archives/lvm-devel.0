From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Dec 2017 11:49:42 -0500
Subject: master - lvmlock: return an error if lvb cannot be written
Message-ID: <201712061649.vB6GngHx027210@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f0f6978e76f2ee55da51b378d951f6e81d7e32d
Commit:        0f0f6978e76f2ee55da51b378d951f6e81d7e32d
Parent:        9e4dc8324117165358f2e329e5f9a5b9f27b1e0a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 6 10:42:43 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 6 10:49:31 2017 -0600

lvmlock: return an error if lvb cannot be written

It doesn't make much difference, because if this happens,
it means there are other more significant problems.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 2171c7a..16db2d6 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1675,7 +1675,7 @@ int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 		if (rv < 0) {
 			log_error("S %s R %s convert_san set_lvb error %d",
 				  ls->name, r->name, rv);
-			rv = -ELMERR;
+			return -ELMERR;
 		}
 	}
 
@@ -1810,7 +1810,7 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 		if (rv < 0) {
 			log_error("S %s R %s unlock_san set_lvb error %d",
 				  ls->name, r->name, rv);
-			rv = -ELMERR;
+			return -ELMERR;
 		}
 	}
 


