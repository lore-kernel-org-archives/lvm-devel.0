From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 19 Mar 2015 11:17:13 +0000 (UTC)
Subject: master - format_text: Fix precommitted segfault.
Message-ID: <20150319111713.CC1826053E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a515a91fcc8df04b5dfd9fe23ef6925c58846af0
Commit:        a515a91fcc8df04b5dfd9fe23ef6925c58846af0
Parent:        e4fa7563853a0f104dec0872760d4acfa08d2554
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 19 11:14:47 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 19 11:14:47 2015 +0000

format_text: Fix precommitted segfault.

The code never mixes reads of committed and precommitted metadata,
so there's no need to attempt to set PRECOMMITTED when
*use_previous_vg is being set.
---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6b09d00..bdac7f9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -551,7 +551,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 				   dev_name(area->dev),
 				   area->start + rlocn->offset, rlocn->size);
 
-	if (precommitted)
+	if (vg && precommitted)
 		vg->status |= PRECOMMITTED;
 
       out:


