From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:55 +0000 (UTC)
Subject: master - cleanup: fold test into printf arg
Message-ID: <20131128114855.4366B60F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfcf3edcc69243cfcef6e73e8bbcba0e60366802
Commit:        bfcf3edcc69243cfcef6e73e8bbcba0e60366802
Parent:        8c96afd361686647e10f3bf70c03dea62b82bc01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 24 18:59:46 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:45:52 2013 +0100

cleanup: fold test into printf arg

When arg is folded, compiler is able to check all args.
(better for security)
---
 lib/metadata/metadata.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5c87ab6..60be61e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -43,9 +43,6 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
-const char _really_init[] =
-    "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
-
 static int _alignment_overrides_default(unsigned long data_alignment,
 					unsigned long default_pe_align)
 {
@@ -1294,7 +1291,8 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	/* prompt */
 	if (pv && !is_orphan(pv) && !pp->yes &&
-	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
+	    yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ",
+			  name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume not initialized", name);
 		goto bad;
 	}


