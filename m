From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Feb 2015 13:39:33 +0000 (UTC)
Subject: master - wiping: blkid: do not count skipped signatures in final number of wipes
Message-ID: <20150219133933.0C40F60DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69b1e32c8a06c77023d2e3440e0abfaeb86808f7
Commit:        69b1e32c8a06c77023d2e3440e0abfaeb86808f7
Parent:        373f8556847a8fdbed3cedd687691d716dca4c5a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 19 13:20:01 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 19 13:30:05 2015 +0100

wiping: blkid: do not count skipped signatures in final number of wipes

We exclude some signatures from being wiped when using blkid wiping.
These are signatures which we simply overwrite. For example, the
LVM2_member signature which denotes a PV - if we call pvcreate on
existing PV, we just overwrite the PV header, no need to wipe it.

Previously, we counted such signatures as if they were wiped
and they were counted in the final number of wiped signatures
that _wipe_known_signatures_with_blkid fn returned in the "wiped"
output arg. Then the code checking this output arg could be
mislead that wiping happened while no wiping took place in real
and we could fire some code uselessly based on this information
(e.g. refreshing filters/rescanning - see also
commit 6b4066585f73df7328ea16f6cb3713cd49cf2d2d).
---
 lib/device/dev-type.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index c7624ac..1649a3a 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -540,7 +540,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 
 	if (!blkid_probe_lookup_value(probe, "TYPE", &type, NULL)) {
 		if (_type_in_flag_list(type, types_to_exclude))
-			return 1;
+			return 2;
 		if (blkid_probe_lookup_value(probe, "SBMAGIC_OFFSET", &offset, NULL)) {
 			log_error(_msg_failed_offset, type, name);
 			return 0;
@@ -600,6 +600,7 @@ static int _wipe_known_signatures_with_blkid(struct device *dev, const char *nam
 {
 	blkid_probe probe = NULL;
 	int found = 0, left = 0, wiped_tmp;
+	int r_wipe;
 	int r = 0;
 
 	if (!wiped)
@@ -626,9 +627,11 @@ static int _wipe_known_signatures_with_blkid(struct device *dev, const char *nam
 						 BLKID_SUBLKS_BADCSUM);
 
 	while (!blkid_do_probe(probe)) {
-		found++;
-		if (_blkid_wipe(probe, dev, name, types_to_exclude, types_no_prompt, yes, force))
+		if ((r_wipe = _blkid_wipe(probe, dev, name, types_to_exclude, types_no_prompt, yes, force)) == 1)
 			(*wiped)++;
+		/* do not count excluded types */
+		if (r_wipe != 2)
+			found++;
 	}
 
 	if (!found)


