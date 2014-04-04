From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 01:38:15 +0000 (UTC)
Subject: master - format_text: Report failed close.
Message-ID: <20140404013815.297D160D66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d7614fcf971d66ccf27e765a110f01a0f2482ea
Commit:        5d7614fcf971d66ccf27e765a110f01a0f2482ea
Parent:        cc72f340d757af537f239689944c934bf9b8fd62
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 02:28:10 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 02:28:10 2014 +0100

format_text: Report failed close.

---
 lib/format_text/format-text.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a1f4a67..071d2b3 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -322,7 +322,8 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 		return_0;
 
 	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
-		(void) dev_close(dev_area->dev);
+		if (!dev_close(dev_area->dev))
+			stack;
 		return_0;
 	}
 


