From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Jul 2019 16:04:10 -0400
Subject: master - pvck: fix looping dump metadata_all
Message-ID: <201907122004.x6CK4AQa029226@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76573137404dafa58795995f5c10dfb5dbc714de
Commit:        76573137404dafa58795995f5c10dfb5dbc714de
Parent:        7230aa891c4186ab425f6821c25101d9049fadde
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 12 12:21:27 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 12 14:09:06 2019 -0500

pvck: fix looping dump metadata_all

dump metadata_all wouldn't quit if the metadata wrapped.
---
 tools/pvck.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 3437164..af2dd8e 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -395,6 +395,9 @@ static int _dump_meta_all(struct device *dev, const char *tofile,
 	search_offset = meta_offset + meta_size;
 
  search_next:
+	if (search_wrapped && (search_offset >= meta_offset + meta_size))
+		goto done;
+
 	if (search_offset > mda_size) {
 		if (search_wrapped)
 			goto done;


