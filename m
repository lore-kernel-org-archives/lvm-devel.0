From: David Teigland <teigland@sourceware.org>
Date: Wed, 28 Oct 2020 21:51:41 +0000 (GMT)
Subject: master - pvck: fix previous commit
Message-ID: <20201028215141.7DFE13858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63169594385ed4b02d93c2e8f422bbeb0b8225af
Commit:        63169594385ed4b02d93c2e8f422bbeb0b8225af
Parent:        125da10d47f4c1f72d3df99f2451c1eb031b9f3a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 28 16:50:47 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 28 16:50:47 2020 -0500

pvck: fix previous commit

line to setup bcache was misplaced in
commit 5a94126e7a28
---
 tools/pvck.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 06fd01733..c36e18216 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3064,11 +3064,11 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_FAILED;
 	}
 
+	label_scan_setup_bcache();
+
 	if (dev) {
 		char buf[4096];
 
-		label_scan_setup_bcache();
-
 		/*
 		 * This buf is not used, but bcache data is used for subsequent
 		 * reads in the filters and by _read_bytes for other disk structs.


