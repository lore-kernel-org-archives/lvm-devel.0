From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jul 2017 13:11:13 -0400
Subject: master - lvmlockd: use lock on thin pool when command names tdata
Message-ID: <201707071711.v67HBD02021715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0f6135e5c53af8bb361932ebe8fec55a1804cc9
Commit:        a0f6135e5c53af8bb361932ebe8fec55a1804cc9
Parent:        fdd00ecdd1fd51605be1b616d712a2220ced8875
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 7 12:06:53 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 7 12:06:53 2017 -0500

lvmlockd: use lock on thin pool when command names tdata

Some lvconvert commands can be used directly on the data sublv:
lvconvert ... vg/pool_tdata

The correct LV lock to use in lvmlockd is the one on the pool LV.
---
 lib/locking/lvmlockd.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 92a970a..34b3882 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2077,6 +2077,10 @@ static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_pool(lv)) {
 		pool_lv = lv;
 
+	} else if (lv_is_thin_pool_data(lv)) {
+		/* FIXME: there should be a function to get pool lv from data lv. */
+		pool_lv = lv_parent(lv);
+
 	} else {
 		/* This should not happen AFAIK. */
 		log_error("Lock on incorrect thin lv type %s/%s",


