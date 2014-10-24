From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:13 +0000 (UTC)
Subject: master - lvcreate: better logging for temporary device
Message-ID: <20141024144013.E460C60317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f7cfea251c07b3a63131320cf4751b91480b9be7
Commit:        f7cfea251c07b3a63131320cf4751b91480b9be7
Parent:        2c057f33f3581aa29f79bb0a62c7115da30f8672
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 21:53:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

lvcreate: better logging for temporary device

Hide creation of temporary LVs and print them only in verbose mode.

e.g. hides confusing message about creation of _pmspare
device during creation of pool.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b197568..e2372e5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Inform about temporarily created volumes only in verbose mode.
   Better support for --test mode with pool creation.
   Query lock holding LV when replacing and converting raid volumes.
   Add extra validate for locked lv within validate_lv_cache_create().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f60b964..6caa284 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7217,7 +7217,10 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 		return_NULL;
 
 out:
-	log_print_unless_silent("Logical volume \"%s\" created", lv->name);
+	if (lp->temporary)
+		log_verbose("Temporary logical volume \"%s\" created.", lv->name);
+	else
+		log_print_unless_silent("Logical volume \"%s\" created.", lv->name);
 
 	return lv;
 }


