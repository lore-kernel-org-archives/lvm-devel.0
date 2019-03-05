From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:59 -0500
Subject: stable-2.02 - dmsetup: Fix multi-line concise table parsing
Message-ID: <201903051353.x25Drx9D006838@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=519f4453a51508e43d36607cc7d1693c79275151
Commit:        519f4453a51508e43d36607cc7d1693c79275151
Parent:        bc6ae7030ad3c620fadce2654c106f78a5bc2350
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 25 13:41:51 2019 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 13:01:40 2019 +0100

dmsetup: Fix multi-line concise table parsing

Use the correct loop variable within the loop, instead of reusing the
initial value.  Table lines after the first don't get terminated in
the right place.

Signed-off-by: Kurt Garloff <kurt@garloff.de>
(cherry picked from commit ccfbd505fea2f259f7c89dc23b020b838363a611)
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a6610a9..bd080b8 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -367,7 +367,7 @@ static int _parse_table_lines(struct dm_task *dmt)
 
 	do {
 		/* Identify and terminate each line */
-		if ((next_pos = strchr(_table, '\n')))
+		if ((next_pos = strchr(pos, '\n')))
 			*next_pos++ = '\0';
 		if (!_parse_line(dmt, pos, "", ++line))
 			return_0;


