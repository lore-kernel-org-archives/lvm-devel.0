From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Feb 2013 10:08:17 +0000 (UTC)
Subject: master - cleanup: remove struct pv_header_extension reference from struct pv_header
Message-ID: <20130227100817.29C708E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9d0e25627f751026b2c486cec97c61ecf2af309
Commit:        a9d0e25627f751026b2c486cec97c61ecf2af309
Parent:        9d5a3c16dd4f5ea64ba3d89ead049a116f728d64
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 27 10:47:24 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 27 10:47:24 2013 +0100

cleanup: remove struct pv_header_extension reference from struct pv_header

Just to prevent accidental and improper use when reading the layout
from disk because of the already existing disk_areas_xl[0] lists
that are variable in size. We can read pv_header_extension only
after we know exactly where the lists end...
---
 lib/format_text/layout.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 92dc582..14f9930 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -43,9 +43,6 @@ struct pv_header {
 	/* NULL-terminated list of data areas followed by */
 	/* NULL-terminated list of metadata area headers */
 	struct disk_locn disk_areas_xl[0];	/* Two lists */
-
-	/* PV header extension */
-	struct pv_header_extension ext;
 } __attribute__ ((packed));
 
 /*


