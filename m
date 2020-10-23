From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:38:04 +0000 (GMT)
Subject: stable-2.02 - filters: persistent filter hides rename failure
Message-ID: <20201023233804.2AF0E3858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e478ef2f59da65ebf47ca7a1534f112669858d5a
Commit:        e478ef2f59da65ebf47ca7a1534f112669858d5a
Parent:        f33ccaee45eb75c3aeac8a6647997de87ff3f207
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 01:27:19 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:31:40 2020 +0200

filters: persistent filter hides rename failure

Filters are saved on command's exit path - and as such they are
not protected by any locks.
This means 2 running commands may 'race' here and 2nd. command
may have already renamed filename for the 1st. command.
So if the rename fails here - we will only use log_sys_debug,
as the failure doesn't cause command failure result.
---
 lib/filters/filter-persistent.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 058694228..afd7eb541 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -272,8 +272,7 @@ static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 		goto_out;
 
 	if (rename(tmp_file, pf->file))
-		log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
-			  strerror(errno));
+		log_sys_debug("rename", tmp_file);
 
 	r = 1;
 


