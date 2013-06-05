From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:22 +0000 (UTC)
Subject: dev-mornfall-lvmcache - metadata: Drop the unused pv_id from format_instance_ctx.
Message-ID: <20130605120622.6B42561057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2d9a818cfc469f928239cef7498c87b4afc43ae
Commit:        a2d9a818cfc469f928239cef7498c87b4afc43ae
Parent:        e83984dca5d477e5ddab7bcaea542b84ffc8fc2a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 14:55:44 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:37 2013 +0200

metadata: Drop the unused pv_id from format_instance_ctx.

---
 lib/metadata/metadata.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 4f504ed..d6da9dd 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -172,7 +172,6 @@ struct device *mda_get_device(struct metadata_area *mda);
 struct format_instance_ctx {
 	uint32_t type;
 	union {
-		const char *pv_id;
 		struct {
 			const char *vg_name;
 			const char *vg_id;


