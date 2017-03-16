From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:02:29 -0400
Subject: master - coverity: update models
Message-ID: <201703160002.v2G02T6e017632@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0dcb928d1e7fb75d6481923effe509237de119de
Commit:        0dcb928d1e7fb75d6481923effe509237de119de
Parent:        115fd205debc1912e6671de802dc571324a2cc93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 14 14:15:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:02:10 2017 +0100

coverity: update models

Latest versions do get quite  strange - so let's use suggestions
from their authors...
---
 coverity/coverity_model.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/coverity/coverity_model.c b/coverity/coverity_model.c
index c5a5bfb..250aadf 100644
--- a/coverity/coverity_model.c
+++ b/coverity/coverity_model.c
@@ -71,6 +71,17 @@ void model_FD_ZERO(void *fdset)
 		((long*)fdset)[i] = 0;
 }
 
+
+/* Resent Coverity reports quite weird errors... */
+int *__errno_location(void)
+{
+}
+const unsigned short **__ctype_b_loc (void)
+{
+}
+
+
+
 /*
  * Added extra pointer check to not need these models,
  * for now just keep then in file


