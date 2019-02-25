From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 25 Feb 2019 08:43:44 -0500
Subject: master - dmsetup: Fix multi-line concise table parsing
Message-ID: <201902251343.x1PDhi95011312@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ccfbd505fea2f259f7c89dc23b020b838363a611
Commit:        ccfbd505fea2f259f7c89dc23b020b838363a611
Parent:        eff33684f774bb732e66898a65c52163d0987b70
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 25 13:41:51 2019 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 25 13:41:51 2019 +0000

dmsetup: Fix multi-line concise table parsing

Use the correct loop variable within the loop, instead of reusing the
initial value.  Table lines after the first don't get terminated in
the right place.

Signed-off-by: Kurt Garloff <kurt@garloff.de>
---
 libdm/dm-tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 2feb419..928b599 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -368,7 +368,7 @@ static int _parse_table_lines(struct dm_task *dmt)
 
 	do {
 		/* Identify and terminate each line */
-		if ((next_pos = strchr(_table, '\n')))
+		if ((next_pos = strchr(pos, '\n')))
 			*next_pos++ = '\0';
 		if (!_parse_line(dmt, pos, "", ++line))
 			return_0;


