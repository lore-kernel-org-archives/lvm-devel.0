From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:19 +0000 (UTC)
Subject: master - _get_pvs: Remove unused variable
Message-ID: <20130702192619.714E360CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ddb1b4abfeeb39044cd26199ff8d966870c2354
Commit:        8ddb1b4abfeeb39044cd26199ff8d966870c2354
Parent:        bfa265f1985818567b1eb6f7fae0ff3ba315b152
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 3 17:05:00 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

_get_pvs: Remove unused variable

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0f71abc..e594f7c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3696,7 +3696,6 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 		struct dm_list *pvslist, struct dm_list *vgslist)
 {
 	struct str_list *strl;
-	struct dm_list * uninitialized_var(results);
 	const char *vgname, *vgid;
 	struct pv_list *pvl, *pvl_copy;
 	struct dm_list *vgids;


