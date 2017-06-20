From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 20 Jun 2017 13:06:45 -0400
Subject: master - lvconvert: provide better reshape reject message for open RaidLV
Message-ID: <201706201706.v5KH6jaQ022699@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1766eaec4b65a3e6d0cd54bca5ed11d73f675d90
Commit:        1766eaec4b65a3e6d0cd54bca5ed11d73f675d90
Parent:        76314183e28321741bec1cb769a7d8a77e5faa81
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 20 19:06:18 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 20 19:06:18 2017 +0200

lvconvert: provide better reshape reject message for open RaidLV

On commits
5e611c700ba1032ffb71bf0cdd33e062e5e16439 and
601ad1c73faa5fe3d74ff5b06cc47073b40a1850.

Related: rhbz1447812
---
 lib/metadata/raid_manip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8a5ae32..290dec7 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -84,7 +84,8 @@ static int _check_lv_open_count(struct logical_volume *lv, int open_count) {
 		return 0;
 	}
 	if (info.open_count != open_count) {
-		log_error("Reshape of open %s not supported.", display_lvname(lv));
+		log_error("Reshape is only supported when %s is not in use (e.g. unmount filesystem).",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -6205,7 +6206,8 @@ static int _lv_open_excl(struct logical_volume *lv, struct device **dev) {
 	if (!(*dev = dev_create_file(dev_path, NULL, NULL, 0)))
 		return_0;
 	if (!dev_open_flags(*dev, O_EXCL, 1, 1)) {
-		log_error("Reshape of open %s not supported.", display_lvname(lv));
+		log_error("Reshape is only supported when %s is not in use (e.g. unmount filesystem).",
+			  display_lvname(lv));
 		return 0;
 	}
 


