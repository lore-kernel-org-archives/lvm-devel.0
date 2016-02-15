From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:40 +0000 (UTC)
Subject: master - metadata: check for PV extension version before doing any checks on PV extension flags
Message-ID: <20160215120840.68C6560509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0b141510523bb09e5a784d6e1b30f106e8dbbf3
Commit:        e0b141510523bb09e5a784d6e1b30f106e8dbbf3
Parent:        d97f1c89deb9a75452059cd62ebb20cf7d2d6bfa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 16 18:23:43 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

metadata: check for PV extension version before doing any checks on PV extension flags

PV header extension versions:
  0 - the original PV without any extensions
  1 - bootloader area support added
  2 - PV_EXT_USED flag support added

So do the associated checks related to PV_EXT_USED flag only if
PV header extension found is of version 2 and higher.
---
 lib/metadata/metadata.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 61084bc..172edc1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3348,9 +3348,21 @@ static int _check_or_repair_orphan_pv_ext(struct physical_volume *pv,
 					  struct lvmcache_info *info,
 					  struct _vg_read_orphan_baton *b)
 {
+	uint32_t ext_version = lvmcache_ext_version(info);
 	uint32_t ext_flags = lvmcache_ext_flags(info);
 	int at_least_one_mda_used;
 
+	/*
+	 * Nothing to do if PV header extension < 2:
+	 *  - version 0 is PV header without any extensions,
+	 *  - version 1 has bootloader area support only and
+	 *    we're not checking anything for that one here.
+	 */
+	if (ext_version < 2) {
+		b->consistent = 1;
+		return 1;
+	}
+
 	if (ext_flags & PV_EXT_USED) {
 		if (lvmcache_mda_count(info)) {
 			at_least_one_mda_used = 0;


