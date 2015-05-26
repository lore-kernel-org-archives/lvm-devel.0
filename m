From: okozina <okozina@fedoraproject.org>
Date: Tue, 26 May 2015 14:29:47 +0000 (UTC)
Subject: master - dmsetup: zero errno in before strtoul call
Message-ID: <20150526142947.A49966052F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8af5f54824f889c438104625dbe159f6e8dedbc4
Commit:        8af5f54824f889c438104625dbe159f6e8dedbc4
Parent:        c069aff21b1450923b59e98ab709a5e667cdcda9
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 26 16:01:40 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 26 16:27:10 2015 +0200

dmsetup: zero errno in before strtoul call

Testing errno value without explicitly setting to
zero in before the strtoul call may lead to
unexpected failures.
---
 tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4202dbb..f200e94 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -914,6 +914,7 @@ static uint32_t _get_cookie_value(const char *str_value)
 	unsigned long int value;
 	char *p;
 
+	errno = 0;
 	if (!(value = strtoul(str_value, &p, 0)) ||
 	    *p ||
 	    (value == ULONG_MAX && errno == ERANGE) ||


