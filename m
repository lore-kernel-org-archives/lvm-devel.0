From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:17 +0000 (UTC)
Subject: master - gcc: cast time_t to 64bit
Message-ID: <20160310174017.855C460EB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e9deb2e701d495819d0a8c75f3a5e6c4240ad48
Commit:        8e9deb2e701d495819d0a8c75f3a5e6c4240ad48
Parent:        5aade9c402e2195bc1742509300983b0d77f33e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 7 18:12:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

gcc: cast time_t to 64bit

Value is printed as uint64, so make sure right type is passed on all
platforms. Fixes gcc warning on some 32bit platforms.
---
 lib/format_text/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 90fb044..c0af3fa 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -664,7 +664,7 @@ static int _print_timestamp(struct formatter *f,
 			      "%Y-%m-%d %T %z", local_tm))
 			buf[0] = 0;
 
-		outfc(f, buf, "%s = %" PRIu64, name, ts);
+		outfc(f, buf, "%s = %" PRIu64, name, (uint64_t) ts);
 	}
 
 	return 1;


