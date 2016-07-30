From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 14:19:12 +0000 (UTC)
Subject: master - lvconvert: Fix --type thin recognition.
Message-ID: <20160730141912.8C42E60F5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48d9c46daabd73c694404c48d3820c2a229f1ad2
Commit:        48d9c46daabd73c694404c48d3820c2a229f1ad2
Parent:        52d2fa7022c48791d003554e5e656a94c5970af8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 15:08:50 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 15:08:50 2016 +0100

lvconvert: Fix --type thin recognition.

lp->thin already holds the result of the cmdline arg resolution.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b9aef53..822df53 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4273,7 +4273,7 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
 		return _convert_striped_snapshot(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN) || arg_is_set(cmd, thin_ARG))
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN) || lp->thin)
 		return _convert_striped_thin(cmd, lv, lp);
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE) || arg_is_set(cmd, cache_ARG))


