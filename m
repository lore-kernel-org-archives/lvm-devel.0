From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 13:58:27 +0000 (UTC)
Subject: master - lvmetad: add missing dev_close in error path
Message-ID: <20140325135827.71C1D61147@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65bbfdf74ddbb16579c4fa5fc76e1f51aee0da22
Commit:        65bbfdf74ddbb16579c4fa5fc76e1f51aee0da22
Parent:        ce78cb58eb84c24c4ba31167f7b7fc03301b454b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 14:53:06 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 14:55:58 2014 +0100

lvmetad: add missing dev_close in error path

Fixes missing dev_close() in dev_read error path
introduced in commit
a36869867275b8ef0f6d324bc5a7f3e2b8e445e9
3e5bec37e9cec455f20656858ba510b69010676d

(in-release fix)
---
 lib/format_text/format-text.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c987cd6..a1f4a67 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -321,8 +321,10 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah))
+	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
+		(void) dev_close(dev_area->dev);
 		return_0;
+	}
 
 	if (!dev_close(dev_area->dev))
 		return_0;


