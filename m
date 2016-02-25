From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:17 +0000 (UTC)
Subject: master - lvresize: fix regression with zero size arg
Message-ID: <20160225223617.6C2FB60AA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a68e601886e1c9b78345b4c33ce366451e2fe184
Commit:        a68e601886e1c9b78345b4c33ce366451e2fe184
Parent:        172bad0d5679f6152281cdd3a69e2cf0a3288c1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 22:44:31 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:29:57 2016 +0100

lvresize: fix regression with zero size arg

Commit ca878a3426197b629c76e98cfc049948da470cd7 introduced an issue
that zero sized extesion suddenly started to be accepted and
missed to return error.

Properly check invalid input values for sizes.
---
 WHATS_NEW        |    1 +
 tools/lvresize.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 378150c..524fea4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Fix regresion when lvresize accepted zero sizes (2.02.141).
   Always warn user about PV in use even when pvremove uses --force --force.
   Use uninitilized pool header detection in all cases.
   Fir read error detection when checking for uninitialized thin-pool header.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 2c2df36..a35a03d 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -47,6 +47,16 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 */
 		lp->sizeargs = arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG);
 
+		if (arg_from_list_is_zero(cmd, "may not be zero",
+					  chunksize_ARG, extents_ARG,
+					  poolmetadatasize_ARG,
+					  regionsize_ARG,
+					  size_ARG,
+					  stripes_ARG, stripesize_ARG,
+					  virtualsize_ARG,
+					  -1))
+			return_0;
+
 		if (arg_count(cmd, poolmetadatasize_ARG)) {
 			lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
 			lp->poolmetadatasign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);


