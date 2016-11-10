From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 10 Nov 2016 16:03:26 +0000 (UTC)
Subject: master - dmsetup: return 0 for [--]{version,help}
Message-ID: <20161110160326.95617608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b1c796420610f015f65530ab68ade6d8119487d
Commit:        0b1c796420610f015f65530ab68ade6d8119487d
Parent:        c1862ea84cdcbb72f4c30a81a7643f39f851e96d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Nov 10 17:03:04 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Nov 10 17:03:04 2016 +0100

dmsetup: return 0 for [--]{version,help}

dmsetup regressed returning 1 when properly processing
version or help subcommands.

Resolves: rhbz1393692
---
 tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4b525e2..371c0f8 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6852,6 +6852,7 @@ doit:
 		}
 	} while (--_count);
 
+	ret = 0;
 out:
 	if (_report)
 		dm_report_free(_report);


