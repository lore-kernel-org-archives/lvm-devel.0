From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:33 +0000 (UTC)
Subject: dev-prajnoha-selout - coverity: ignore ret val
Message-ID: <20140509065633.158BD60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcd6deea18673cedfa833fc40399949955e7f834
Commit:        bcd6deea18673cedfa833fc40399949955e7f834
Parent:        d11617864a6434c3775e1fbc8c55af6d3ae5dc57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 11:22:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:12 2014 +0200

coverity: ignore ret val

Since we intentionaly do not want to check them,
cast result values to void.
---
 lib/device/dev-type.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 193e9bd..9d610d4 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -495,9 +495,10 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 	offset_value = strtoll(offset, NULL, 10);
 
 	if (!usage)
-		blkid_probe_lookup_value(probe, "USAGE", &usage, NULL);
-	blkid_probe_lookup_value(probe, "LABEL", &label, NULL);
-	blkid_probe_lookup_value(probe, "UUID", &uuid, NULL);
+		(void) blkid_probe_lookup_value(probe, "USAGE", &usage, NULL);
+	(void) blkid_probe_lookup_value(probe, "LABEL", &label, NULL);
+	(void) blkid_probe_lookup_value(probe, "UUID", &uuid, NULL);
+	/* Return values ignored here, in the worst case we print NULL */
 
 	log_verbose("Found existing signature on %s at offset %s: LABEL=\"%s\" "
 		    "UUID=\"%s\" TYPE=\"%s\" USAGE=\"%s\"",


