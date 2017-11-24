From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:16 -0500
Subject: master - toollib: avoid printing default stripe size
Message-ID: <201711241511.vAOFBGF0000737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b5c5cc618bbfaa2945d6fe2211443b28588764a
Commit:        5b5c5cc618bbfaa2945d6fe2211443b28588764a
Parent:        16ef133be2a6aaa0d16078326e739d19eaf5f66b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 17 23:02:44 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

toollib: avoid printing default stripe size

When user is not creating striped LV, do not print
rather confusing info about default stripe size.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c27db7c..f78b6c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Fix printing of default stripe size when user is not using stripes.
   Activation code for pvmove automatically discovers holding LVs for resume.
   Make a pvmove LV locking holder.
   Do not change critical section counter on resume path without real resume.
diff --git a/tools/toollib.c b/tools/toollib.c
index 9b88341..ffd9a4d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1271,7 +1271,7 @@ static int _validate_stripe_params(struct cmd_context *cmd, const struct segment
 	if (!stripe_size_required && *stripe_size) {
 		log_print_unless_silent("Ignoring stripesize argument for %s devices.", segtype->name);
 		*stripe_size = 0;
-	} else if (*stripes == 1 && (segtype_is_striped_target(segtype) || segtype_is_mirror(segtype))) {
+	} else if (*stripes == 1 && stripe_size_required) {
 		stripe_size_required = 0;
 		if (*stripe_size) {
 			log_print_unless_silent("Ignoring stripesize argument with single stripe.");


