From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:09 +0000 (UTC)
Subject: master - lvconvert: disallow usage of origin for snapshot
Message-ID: <20140317133309.C54E160F27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3b9ee37e9b9672929737dedcd52b46f57d93d23
Commit:        f3b9ee37e9b9672929737dedcd52b46f57d93d23
Parent:        455f23586f0125fb2763c0f2f48e79bc08d9e2c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 09:41:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:42 2014 +0100

lvconvert: disallow usage of origin for snapshot

Usage of origin as a snapshot 'COW' volume is unsupported.

Without this test lvm2 is able to generate this ugly internal error message.

To test this:

lvcreate -L1 -n lv1 vg
lvcreate -L1 -n lv2 -s vg/lv1
lvcreate -L1 -n lv3 vg
lvconvert -s vg/lv3 vg/lv1

Internal error: LVs (5) != visible LVs (1) + snapshots (1) + internal LVs (0) in VG vg
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2d91981..c3c8aff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Disallow lvconvert of origin to snapshot COW volume.
   Make report settings profilable.
   Add existing report settings to lvm.conf.
   Use VG read lock during 'pvscan --cache -aay' autoactivation.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c8cc506..1b9d9f7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2038,6 +2038,12 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 {
 	struct logical_volume *org;
 
+	if (lv_is_origin(lv)) {
+		/* Unsupported stack */
+		log_error("Unable to convert origin \"%s\" into a snapshot.", lv->name);
+		return 0;
+	}
+
 	if (!(org = find_lv(lv->vg, lp->origin))) {
 		log_error("Couldn't find origin volume '%s'.", lp->origin);
 		return 0;


