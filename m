From: okozina <okozina@fedoraproject.org>
Date: Tue, 26 May 2015 14:29:45 +0000 (UTC)
Subject: master - lvmpolld: zero errno in before strtoul call
Message-ID: <20150526142945.842BD6052F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c069aff21b1450923b59e98ab709a5e667cdcda9
Commit:        c069aff21b1450923b59e98ab709a5e667cdcda9
Parent:        a72a80589689961285ec6aacff99087ddd8c378d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 26 15:55:16 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 26 16:27:03 2015 +0200

lvmpolld: zero errno in before strtoul call

Testing errno value without explicitly setting to
zero in before the strtoul call may lead to
unexpected failures.
---
 daemons/lvmpolld/lvmpolld-core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 1a33625..c1d583e 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -749,6 +749,7 @@ static int process_timeout_arg(const char *str, unsigned *max_timeouts)
 	char *endptr;
 	unsigned long l;
 
+	errno = 0;
 	l = strtoul(str, &endptr, 10);
 	if (errno || *endptr || l >= UINT_MAX)
 		return 0;


