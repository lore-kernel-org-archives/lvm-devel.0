From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:32 +0000 (UTC)
Subject: dev-mornfall-lvmcache - clvmd: avoid pretesting of dev availability
Message-ID: <20130605120232.5A88C61457@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d51b7e54044518ed8e20ce3ea617a28d2313730d
Commit:        d51b7e54044518ed8e20ce3ea617a28d2313730d
Parent:        320d7f3596f78972d5fa843b9d56510ff299a958
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 10:11:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:22 2013 +0200

clvmd: avoid pretesting of dev availability

Patch fixes hidden problem with lvm metadata caching.

When the pretest was made, only the commited data have been cached back
since the call lv_info_by_lvid() triggers mda read operation.
However call of lv_suspend_if_active() also reads precommited metadata.
The problem is visible in this sequence of calls:

vg_write(), suspend_lv(), vg_commit(), resume_lv()

which may end with leaving outdated mda in lvm cache, since vg_write()
drops cached metadata and vg_commit() only transforms precommited
to commited metadata, but in the case of pretesting we have
no precommited mda available so the cache will continue to use
old metadata. This happens, when suspend LV is inactive.
---
 WHATS_NEW                     |    1 +
 daemons/clvmd/lvm-functions.c |    9 ++-------
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4139557..ceaed00 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix clvmd caching of metadata when suspending inactive volumes.
   Find newest timestamp of merged config files.
   Fix assignment order for vg fid for lvm1 and pool format.
   Fix memleak in dmeventd thin plugin in device list obtaining err path.
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 6d78090..5e83454 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -437,7 +437,6 @@ static int do_resume_lv(char *resource, unsigned char command, unsigned char loc
 static int do_suspend_lv(char *resource, unsigned char command, unsigned char lock_flags)
 {
 	int oldmode;
-	struct lvinfo lvi;
 	unsigned origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
 	unsigned exclusive;
 
@@ -450,12 +449,8 @@ static int do_suspend_lv(char *resource, unsigned char command, unsigned char lo
 
 	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
 
-	/* Only suspend it if it exists */
-	if (!lv_info_by_lvid(cmd, resource, origin_only, &lvi, 0, 0))
-		return EIO;
-
-	if (lvi.exists &&
-	    !lv_suspend_if_active(cmd, resource, origin_only, exclusive))
+	/* Always call lv_suspend to read commited and precommited data */
+	if (!lv_suspend_if_active(cmd, resource, origin_only, exclusive))
 		return EIO;
 
 	return 0;


