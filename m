From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Apr 2014 11:33:37 +0000 (UTC)
Subject: master - tools: don't require --major to be specified when using -My option on kernels > 2.4
Message-ID: <20140404113337.3760060EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7c930b18da8f8179312e395c49f72080edd687e
Commit:        a7c930b18da8f8179312e395c49f72080edd687e
Parent:        4d0c3ed0f89ed25707c0a16049dfb9da647ed842
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 4 13:29:39 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 4 13:29:39 2014 +0200

tools: don't require --major to be specified when using -My option on kernels > 2.4

Since kernel > 2.4 have dynamically assigned major numbers.

[0] raw/~ $ lvcreate -l1 -My --minor 10 vg
  Logical volume "lvol0" created

[0] raw/~ $ lvcreate -l1 -My --major 254 --minor 11 vg
  Ignoring supplied major number - kernel assigns major numbers dynamically. Using major number 253 instead.
  Logical volume "lvol1" created

[0] raw/~ $ lvs --profile out -o+major,minor
  lvol0 vg     -wima-----    4.00 253  10
  lvol1 vg     -wima-----    4.00 253  11
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   16 ++++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dd3b42f..1888cfd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Don't require --major to be specified when using -My option on kernels > 2.4.
   Add configure --disable-thin_check_needs_check to support old thin_check.
   Use thin_check --clear-needs-check-flag by default.
   Export lvm_even_rand() for controlled provision of random numbers.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ad00327..c612465 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -804,10 +804,18 @@ static int _read_activation_params(struct lvcreate_params *lp,
 					  "--minor when using -My");
 				return 0;
 			}
-			if (lp->major == -1) {
-				log_error("Please specify major number with "
-					  "--major when using -My");
-				return 0;
+			if (!strncmp(cmd->kernel_vsn, "2.4.", 4)) {
+				if (lp->major == -1) {
+					log_error("Please specify major number with "
+						  "--major when using -My");
+					return 0;
+				}
+			} else {
+				if (lp->major >= 0)
+					log_warn("Ignoring supplied major number - kernel assigns "
+						 "major numbers dynamically. Using major number %d instead.",
+						  cmd->dev_types->device_mapper_major);
+				lp->major = cmd->dev_types->device_mapper_major;
 			}
 			if (!major_minor_valid(cmd, vg->fid->fmt, lp->major, lp->minor))
 				return 0;


