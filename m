From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:24 +0000 (UTC)
Subject: master - thin: order discard enum alphabetically
Message-ID: <20120807203024.B05E93283@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=adfa778a58719cb78971526b68a93cee56a18cc4
Commit:        adfa778a58719cb78971526b68a93cee56a18cc4
Parent:        4dab0d3175a9bc6658611f06ba8b0c05b40e06bd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 18:36:40 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 18:36:40 2012 +0100

thin: order discard enum alphabetically

---
 lib/metadata/metadata-exported.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d2afdb1..35ffa93 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -167,9 +167,9 @@ typedef enum {
 } force_t;
 
 typedef enum {
-	THIN_DISCARD_PASSDOWN,
-	THIN_DISCARD_NO_PASSDOWN,
 	THIN_DISCARD_IGNORE,
+	THIN_DISCARD_NO_PASSDOWN,
+	THIN_DISCARD_PASSDOWN,
 } thin_discard_t;
 
 struct cmd_context;


