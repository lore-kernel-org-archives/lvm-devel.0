From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Jul 2014 10:32:06 +0000 (UTC)
Subject: master - dev-type: print aborting log_error
Message-ID: <20140704103206.2B5F860C22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f72f8ed40a6cf72d424118cbb57d8a5961cc891
Commit:        1f72f8ed40a6cf72d424118cbb57d8a5961cc891
Parent:        a94abc0fdd33b31cd292d9b9a61ddceb7b72208f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 3 12:15:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 4 12:31:17 2014 +0200

dev-type: print aborting log_error

When wiping is aborted print immediate log_error message
(log_error comes 1st.)
---
 lib/device/dev-type.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 0d91017..902b7d1 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -507,8 +507,10 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 	if (!_type_in_flag_list(type, types_no_prompt)) {
 		if (!yes && (force == PROMPT) &&
 		    yes_no_prompt("WARNING: %s signature detected on %s at offset %s. "
-				  "Wipe it? [y/n] ", type, name, offset) != 'y')
-			return_0;
+				  "Wipe it? [y/n]: ", type, name, offset) == 'n') {
+			log_error("Aborted wiping of %s.", type);
+			return 0;
+		}
 		log_print_unless_silent(_msg_wiping, type, name);
 	} else
 		log_verbose(_msg_wiping, type, name);
@@ -591,9 +593,11 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 
 	/* Specifying --yes => do not ask. */
 	if (!yes && (force == PROMPT) &&
-	    yes_no_prompt("WARNING: %s detected on %s. Wipe it? [y/n] ",
-			  type, name) != 'y')
-		return_0;
+	    yes_no_prompt("WARNING: %s detected on %s. Wipe it? [y/n]: ",
+			  type, name) == 'n') {
+		log_error("Aborted wiping of %s.", type);
+		return 0;
+	}
 
 	log_print_unless_silent("Wiping %s on %s.", type, name);
 	if (!dev_set(dev, offset_found, wipe_len, 0)) {


