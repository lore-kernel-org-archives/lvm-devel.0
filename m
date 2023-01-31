From: David Teigland <teigland@sourceware.org>
Date: Tue, 31 Jan 2023 21:30:56 +0000 (GMT)
Subject: main - pvscan: recognize "pci" as a common symlink component in filters
Message-ID: <20230131213056.62A103858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d14144d311fb347e4225ad6a48d4900b39445c4
Commit:        6d14144d311fb347e4225ad6a48d4900b39445c4
Parent:        c9fdc828ff0504bc2e57f65862bc382f7663a8a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 27 16:46:03 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 31 15:30:35 2023 -0600

pvscan: recognize "pci" as a common symlink component in filters

In case the filter strings don't include "/dev/disk", and only
include "pci".
---
 lib/filters/filter-regex.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 40dc8aa1b..ecc32914b 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -284,6 +284,8 @@ static int _filter_contains_symlink(struct cmd_context *cmd, int filter_cfg)
 				return 1;
 			if (strstr(fname, "wwn-"))
 				return 1;
+			if (strstr(fname, "pci-"))
+				return 1;
 		}
 	}
 

