From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Feb 2015 12:42:41 +0000 (UTC)
Subject: master - cleanup: fix compate of return value
Message-ID: <20150217124241.C683D60090@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a009c0fb407ec3a16e0432cb29434b9e9e79d81b
Commit:        a009c0fb407ec3a16e0432cb29434b9e9e79d81b
Parent:        4bb60c05bfc5b1be101807302e0697a4508dd98c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 17 13:40:35 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 17 13:40:35 2015 +0100

cleanup: fix compate of return value

Drop '!' for 'ret' compare.
Since the effect of false compare was only stack trace printing,
it present no real code flow change.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3bbe65f..935cbf9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3519,7 +3519,7 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 		 */
 		unlock_vg(cmd, vg_name);
 
-		if (!(ret = _poll_logical_volume(cmd, lp->lv_to_poll,
+		if ((ret = _poll_logical_volume(cmd, lp->lv_to_poll,
 						 lp->wait_completion)) != ECMD_PROCESSED)
 			stack;
 


