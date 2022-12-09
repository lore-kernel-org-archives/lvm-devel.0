From: David Teigland <teigland@sourceware.org>
Date: Fri,  9 Dec 2022 14:51:41 +0000 (GMT)
Subject: main - lvchange: handle unrecognized writecache setting
Message-ID: <20221209145141.E140A38388F8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ce55a43d0165da9827e7b8e75bf25583a571e89
Commit:        9ce55a43d0165da9827e7b8e75bf25583a571e89
Parent:        6613a61d3b5ce4d12a6fef79195eac34f30ef4da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 8 15:48:30 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 8 15:48:30 2022 -0600

lvchange: handle unrecognized writecache setting

It was being ignored.
---
 tools/lvchange.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 34c9e36fd..dfbefa000 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -665,6 +665,11 @@ static int _lvchange_writecache(struct cmd_context *cmd,
 		seg->writecache_settings.max_age = settings.max_age;
 		set_count++;
 	}
+	if (settings.new_key && settings.new_val) {
+		seg->writecache_settings.new_key = settings.new_key;
+		seg->writecache_settings.new_val = settings.new_val;
+		set_count++;
+	}
 
 	if (!set_count) {
 		/*

