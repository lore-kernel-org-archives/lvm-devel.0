From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Aug 2016 23:00:39 +0000 (UTC)
Subject: master - lvcreate: Never treat raid0 as linear.
Message-ID: <20160819230039.43DC360AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=896912b14d80e49582759d0c5b14b16954b3857d
Commit:        896912b14d80e49582759d0c5b14b16954b3857d
Parent:        88e6abc5a091bbe8d826968eafe27936df0e260c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 19 23:57:30 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 19 23:57:30 2016 +0100

lvcreate: Never treat raid0 as linear.

raid0 and raid0_meta require, or default to, at least 2 stripes.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 4f4c315..ec6f2f7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1281,7 +1281,7 @@ static int _validate_stripe_params(struct cmd_context *cmd, const struct segment
 	if (!stripe_size_required && *stripe_size) {
 		log_print_unless_silent("Ignoring stripesize argument for %s devices.", segtype->name);
 		*stripe_size = 0;
-	} else if (*stripes == 1 && (segtype_is_striped(segtype) || segtype_is_mirror(segtype))) {
+	} else if (*stripes == 1 && (segtype_is_striped_target(segtype) || segtype_is_mirror(segtype))) {
 		stripe_size_required = 0;
 		if (*stripe_size) {
 			log_print_unless_silent("Ignoring stripesize argument with single stripe.");


