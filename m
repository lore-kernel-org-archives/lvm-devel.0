From: Malahal Naineni <malahal@us.ibm.com>
Date: Mon, 07 Dec 2009 06:43:36 -0800
Subject: [PATCH] Fix activated/deactivated log message
Message-ID: <8b2a589b8b023ec44167.1260197016@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I see "Deactivated" message when I activate and "Activated" message when
I deactivate.  The code uses "activate" as boolean but it can be any one
of the enum values from CHANGE_AY, CHANGE_AN, CHANGE_AE, etc.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>

diff -r b435737bd332 -r 8b2a589b8b02 tools/vgchange.c
--- a/tools/vgchange.c	Mon Dec 07 01:07:01 2009 -0800
+++ b/tools/vgchange.c	Mon Dec 07 06:39:17 2009 -0800
@@ -104,8 +104,8 @@ static int _activate_lvs_in_vg(struct cm
 
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
-			    activate ? "Activated" : "Deactivated",
-			    count, vg->name);
+			    (activate == CHANGE_AN || activate == CHANGE_ALN)?
+			    "Deactivated" : "Activated", count, vg->name);
 
 	return (expected_count != count) ? ECMD_FAILED : ECMD_PROCESSED;
 }


