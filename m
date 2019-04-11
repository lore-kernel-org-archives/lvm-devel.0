From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Apr 2019 11:33:52 -0400
Subject: master - hints: fix case of error getting device size
Message-ID: <201904111533.x3BFXqrn017705@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0cc80ccfd5215073f0f0b0aa3c2913076ae01751
Commit:        0cc80ccfd5215073f0f0b0aa3c2913076ae01751
Parent:        25f231cf06c3938838a64f5b88834d831f45c1c2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 11 10:32:28 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 11 10:32:28 2019 -0500

hints: fix case of error getting device size

When checking hints, if there's an error getting
the device size, that should be equivalent to
seeing zero size.
---
 lib/label/hints.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index a2e7646..eb0e725 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -414,7 +414,7 @@ static int _dev_in_hint_hash(struct cmd_context *cmd, struct device *dev)
 	if (!cmd->scan_lvs && dm_is_dm_major(MAJOR(dev->dev)) && dev_is_lv(dev))
 		return 0;
 
-	if (dev_get_size(dev, &devsize) && !devsize)
+	if (!dev_get_size(dev, &devsize) || !devsize)
 		return 0;
 
 	return 1;
@@ -604,6 +604,8 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	if (!(fp = fopen(_hints_file, "r")))
 		return 0;
 
+	log_debug("Reading hint file");
+
 	for (i = 0; i < HINT_LINE_WORDS; i++)
 		split[i] = NULL;
 


