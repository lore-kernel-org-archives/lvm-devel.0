From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Mon, 14 May 2018 17:18:19 -0400
Subject: master - clean-up: example.conf.in typo
Message-ID: <201805142118.w4ELIJLQ006592@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2eba7c77557655cfbd19f191ec5d1ad1025897b3
Commit:        2eba7c77557655cfbd19f191ec5d1ad1025897b3
Parent:        11ceb77867560e0b804df5ec3162e9cbdc9ed321
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon May 14 16:17:01 2018 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon May 14 16:17:01 2018 -0500

clean-up: example.conf.in typo

---
 conf/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 92af8d3..4c62aad 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -702,7 +702,7 @@ global {
 	activation = 1
 
 	# Configuration option global/fallback_to_lvm1.
-	# This setting setting no longer used.
+	# This setting is no longer used.
 	# This configuration option has an automatic default value.
 	# fallback_to_lvm1 = 0
 


