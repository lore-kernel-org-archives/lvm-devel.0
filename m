From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:39 +0000 (UTC)
Subject: master - cleanup: assignment into ()
Message-ID: <20140829111239.35E1260FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19375e4fcabea7ffcf2b249f6738218b3885c871
Commit:        19375e4fcabea7ffcf2b249f6738218b3885c871
Parent:        db77041d93a946384cadecdb3a33466e09f77b00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 28 13:53:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:11:34 2014 +0200

cleanup: assignment into ()

Put is_float=1 into () - so the intention is obvious.
Remove uneeded extra check for for  *s != 0,
since it's already checked for either digit or '.'.
---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index cd42b11..6e7167f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1721,7 +1721,7 @@ static const char *_tok_value_number(const char *s,
 	int is_float = 0;
 
 	*begin = s;
-	while (*s && ((!is_float && *s=='.' && (is_float=1)) || isdigit(*s)))
+	while ((!is_float && (*s == '.') && ((is_float = 1))) || isdigit(*s))
 		s++;
 	*end = s;
 


