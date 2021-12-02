From: David Teigland <teigland@sourceware.org>
Date: Thu,  2 Dec 2021 18:41:26 +0000 (GMT)
Subject: main - print warning about unrecognized journal option value
Message-ID: <20211202184126.9CE46385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=455c29b10dfd15a9fa2ad72c8f9de77572328d39
Commit:        455c29b10dfd15a9fa2ad72c8f9de77572328d39
Parent:        c42a05c3ec8608e438fca435e3cbe6d306af80c6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 2 12:40:52 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 2 12:40:52 2021 -0600

print warning about unrecognized journal option value

---
 lib/log/log.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/log/log.c b/lib/log/log.c
index 7b4d537b3..5771a1d01 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -892,6 +892,7 @@ uint32_t log_journal_str_to_val(const char *str)
 		return LOG_JOURNAL_OUTPUT;
 	if (!strcasecmp(str, "debug"))
 		return LOG_JOURNAL_DEBUG;
+	log_warn("Ignoring unrecognized journal value.");
 	return 0;
 }
 


