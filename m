From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:37 +0000 (UTC)
Subject: master - lvresize: inform about ignored args with --use-polices
Message-ID: <20160623130137.2675B60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d578d8d3a1bbf5d20151ed8bc33caa307e2c7292
Commit:        d578d8d3a1bbf5d20151ed8bc33caa307e2c7292
Parent:        58d414f7f5d998e32234e7a6c2d6c9d0ad38f996
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 14 13:40:57 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:08 2016 +0200

lvresize: inform about ignored args with --use-polices

When --use-polices is specified, all size args are meaningless,
as the resize is based upon policy. So just keep user informed.
---
 tools/lvresize.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index fe200d4..9fb35bd 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -37,6 +37,15 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->extents = 0;
 		lp->sign = SIGN_PLUS;
 		lp->percent = PERCENT_LV;
+
+		if (arg_from_list_is_set(cmd, NULL,
+					 chunksize_ARG, extents_ARG,
+					 poolmetadatasize_ARG,
+					 regionsize_ARG,
+					 size_ARG,
+					 stripes_ARG, stripesize_ARG,
+					 -1))
+			log_print_unless_silent("Ignoring size parameters with --use-policies.");
 	} else {
 		/*
 		 * Allow omission of extents and size if the user has given us


