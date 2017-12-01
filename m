From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 12:38:33 -0500
Subject: master - lv_manip: allow extension on --nosync raid lv
Message-ID: <201712011738.vB1HcXE9027181@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4daad1cf11d9bb16ff6d8f3adc0918cbacfbe398
Commit:        4daad1cf11d9bb16ff6d8f3adc0918cbacfbe398
Parent:        3688eeeea0a81e8dbc02d1c9d46cb983a4d8d79b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:38:18 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:38:18 2017 +0100

lv_manip: allow extension on --nosync raid lv

If the recovery of the repleced leg(s) of a RaidLV created without
initial resynchronization (i.e. "lvcreate --nosync ...") got
interrupted, it can't be extended because of the < 100% sync rate.
---
 lib/metadata/lv_manip.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fb152ac..6b2d1f1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4233,7 +4233,8 @@ int lv_extend(struct logical_volume *lv,
 				log_error("Failed to get sync percent for %s.",
 					  display_lvname(lv));
 				goto out;
-			} else if (sync_percent == DM_PERCENT_100) {
+			} else if (lv_is_not_synced(lv) ||
+				   sync_percent == DM_PERCENT_100) {
 				log_verbose("Skipping initial resync for "
 					    "extended portion of %s",
 					    display_lvname(lv));


