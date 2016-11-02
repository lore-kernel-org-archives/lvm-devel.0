From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:32:12 +0000 (UTC)
Subject: master - pvscan: fix autoactivation of exported VG
Message-ID: <20161102213212.AEE266056C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68e7d3496517a70e50edaceff906ad1da23821a6
Commit:        68e7d3496517a70e50edaceff906ad1da23821a6
Parent:        4585785613320f2400b5645a47375308f1ee5289
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 2 16:29:52 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 2 16:29:52 2016 -0500

pvscan: fix autoactivation of exported VG

pvscan --cache -aay was activating LVs in exported VGs
when it should not.

It appears that this was a regression from commit 9b640c36841
"pvscan: use process_each_vg for autoactivate".
---
 tools/pvscan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index f5367e4..e2b0a83 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -194,6 +194,9 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 	if (vg_is_clustered(vg))
 		return ECMD_PROCESSED;
 
+	if (vg_is_exported(vg))
+		return ECMD_PROCESSED;
+
 	if (is_lockd_type(vg->lock_type))
 		return ECMD_PROCESSED;
 


