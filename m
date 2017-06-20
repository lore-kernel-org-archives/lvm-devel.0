From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Jun 2017 12:25:48 -0400
Subject: master - tests: avoid double lines
Message-ID: <201706201625.v5KGPm2T006816@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d591ac376b369de78d8471c2651256c5eb52b1f
Commit:        3d591ac376b369de78d8471c2651256c5eb52b1f
Parent:        1ea41b6d486cc34bf55e51eaac60f2cadfc866c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 20 17:15:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 20 18:24:52 2017 +0200

tests: avoid double lines

Skip showing same line twice in test's verbose log.
---
 test/lib/check.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 64812fb..5eec936 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -411,7 +411,7 @@ raid_leg_status() {
 
 grep_dmsetup() {
 	dmsetup $1 $2 | tee out
-	grep "${@:3}" out || die "Expected output from dmsetup $1 not found!"
+	grep -q "${@:3}" out || die "Expected output \"${@:3}\" from dmsetup $1 not found!"
 }
 
 #set -x


