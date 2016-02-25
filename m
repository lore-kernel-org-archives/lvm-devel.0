From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 18:01:35 +0000 (UTC)
Subject: master - pvcreate: fix setting uuid arg
Message-ID: <20160225180135.5026F6066E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66e175702af4cfb1ecad9316a8151c001933c190
Commit:        66e175702af4cfb1ecad9316a8151c001933c190
Parent:        79f259621542e62a2f9fb5982f473d2bb849b1b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 25 11:56:24 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 12:00:53 2016 -0600

pvcreate: fix setting uuid arg

Commit 4de6caf5 ("redefine pvcreate structs") left
out setting the "idp" pointer to the "id" arg.
---
 tools/pvcreate.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 85fed09..77f5969 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -49,6 +49,7 @@ static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
 		pp->uuid_str = arg_str_value(cmd, uuidstr_ARG, "");
 		if (!id_read_format(&pp->pva.id, pp->uuid_str))
 			return 0;
+		pp->pva.idp = &pp->pva.id;
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {


