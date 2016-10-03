From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:05 +0000 (UTC)
Subject: master - libdm: check for mem when _canonicalize_field_ids
Message-ID: <20161003155105.90E3E60A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d70f1127624fa64ee691eb4c9d4bce5a4845f985
Commit:        d70f1127624fa64ee691eb4c9d4bce5a4845f985
Parent:        ee04f1fcfd915af927ad19c3952e211158f4df0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 16:29:55 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:46:26 2016 +0200

libdm: check for mem when _canonicalize_field_ids

Add missing check for dm_pool_strdup() call (Coverity).
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6186737..4303dc9 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Check mem alloc fail in _canonicalize_field_ids().
   Use unsigned math when checking more then 31 legs of raid.
   Fix 'dmstats delete' with dmsetup older than v1.02.129
   Fix stats walk segfault with dmsetup older than v1.02.129
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index fed79d4..ebd2439 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1228,7 +1228,10 @@ static int _canonicalize_field_ids(struct dm_report *rh)
 			return_0;
 
 		if (differs) {
-			canonical_field_dup = dm_pool_strdup(rh->mem, canonical_field);
+			if (!(canonical_field_dup = dm_pool_strdup(rh->mem, canonical_field))) {
+				log_error("_canonicalize_field_dup: dm_pool_alloc failed.");
+				return 0;
+			}
 			rh->canonical_field_ids[i] = canonical_field_dup;
 		} else
 			rh->canonical_field_ids[i] = rh->fields[i].id;


