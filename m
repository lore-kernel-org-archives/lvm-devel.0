From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 10 Nov 2016 17:10:16 +0000 (UTC)
Subject: master - dmsetup: [v2] return 0 for [--]{version, help}
Message-ID: <20161110171016.D969760733@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b11f4f93d70d307b997290713607c0742c3ea29e
Commit:        b11f4f93d70d307b997290713607c0742c3ea29e
Parent:        0b1c796420610f015f65530ab68ade6d8119487d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Nov 10 18:09:37 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Nov 10 18:09:37 2016 +0100

dmsetup: [v2] return 0 for [--]{version,help}

Leverage 0b1c79642061 to cope with "dmsetup SubCommand --{help,version}"
and bail out directly when _report_init() fails.

Related: rhbz1393692
---
 tools/dmsetup.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 371c0f8..e48f0a6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6798,7 +6798,7 @@ unknown:
 	if (_switches[COLS_ARG]) {
 		if (!_report_init(cmd, subcommand))
 			ret = 1;
- 		if (!_report)
+		if (ret || !_report)
 			goto_out;
 	}
 
@@ -6852,7 +6852,6 @@ doit:
 		}
 	} while (--_count);
 
-	ret = 0;
 out:
 	if (_report)
 		dm_report_free(_report);
@@ -6865,5 +6864,5 @@ out:
 	if (_initial_timestamp)
 		dm_timestamp_destroy(_initial_timestamp);
 
-	return ret;
+	return (_switches[HELP_ARG] || _switches[VERSION_ARG]) ? 0 : ret;
 }


