From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Oct 2013 11:37:45 +0000 (UTC)
Subject: master - metadata: properly register LV_NOSCAN flag
Message-ID: <20131010113745.ABA0D60D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=029b8fbe767e63f1d0a4f6c81a0095af46e9a000
Commit:        029b8fbe767e63f1d0a4f6c81a0095af46e9a000
Parent:        304159c99ab59c61543cac747e47a1ff59d2dbb6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 10 13:24:32 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 10 13:24:32 2013 +0200

metadata: properly register LV_NOSCAN flag

Addendum to commit ce7489e which introduced a new *internal* LV_NOSCAN
flag and so it needs to be marked that way properly otherwise it
ends up unrecognized and improperly handled during metadata export.
---
 lib/format_text/flags.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 5077576..6801d6c 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -61,6 +61,7 @@ static const struct flag _lv_flags[] = {
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
+	{LV_NOSCAN, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},


