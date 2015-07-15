From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:11:01 +0000 (UTC)
Subject: master - cleanup: avoid double assign
Message-ID: <20150715111101.D0768609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c45e6e3c78bc6ac4ddd96c764deed211cf1c6f31
Commit:        c45e6e3c78bc6ac4ddd96c764deed211cf1c6f31
Parent:        a7101e7bfb1b8f5f792974a3b5f39fa4fcdb5656
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 10 11:16:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

cleanup: avoid double assign

Variable n1 is assigned without using n1 before.
---
 libdm/libdm-report.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index c08dcab..34374bb 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2595,7 +2595,7 @@ static char *_get_date(char *str, struct tm *tm, time_range_t *range)
 {
 	static const char incorrect_date_format_msg[] = "Incorrect date format.";
 	time_range_t tmp_range = RANGE_NONE;
-	long n1 = -1, n2 = -1, n3 = -1;
+	long n1, n2 = -1, n3 = -1;
 	char *s = str, *end;
 	size_t len = 0;
 
@@ -2680,7 +2680,7 @@ static char *_get_time(char *str, struct tm *tm, time_range_t *range)
 {
 	static const char incorrect_time_format_msg[] = "Incorrect time format.";
 	time_range_t tmp_range = RANGE_NONE;
-	long n1 = -1, n2 = -1, n3 = -1;
+	long n1, n2 = -1, n3 = -1;
 	char *s = str, *end;
 	size_t len = 0;
 
@@ -2774,7 +2774,7 @@ static char *_get_time(char *str, struct tm *tm, time_range_t *range)
 /* The offset is always an absolute offset against GMT! */
 static char *_get_tz(char *str, int *tz_supplied, int *offset)
 {
-	long n1 = -1, n2 = -1;
+	long n1, n2 = -1;
 	char *s = str, *end;
 	int sign = 1; /* +HH:MM by default */
 	size_t len = 0;


