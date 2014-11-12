From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Nov 2014 08:36:16 +0000 (UTC)
Subject: master - coverity: remove redundant condition
Message-ID: <20141112083616.02AFB60E7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eccc97f15a0f2e19f5ccc714cb4880644b4772df
Commit:        eccc97f15a0f2e19f5ccc714cb4880644b4772df
Parent:        ba2302346433af7150193025aa8a446fa3238445
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 12 09:30:02 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 12 09:30:02 2014 +0100

coverity: remove redundant condition

LVM2.2.02.112/daemons/clvmd/clvmd.c:1131: warning[arrayIndexOutOfBoundsCond]: Array 'row[8]' accessed at index 8, which is out of bounds. Otherwise condition 'j==8' is redundant.

This code:

int i,j = 0;
...
for (i = 0; i < len; ++i) {
	...
	if ((j == 8) || (i + 1 == len)) {
		for (;j < 8; ++j) {
			...
		}
		...
		j = 0;
	}
}

Indeed - j is 0 at the beginning, then iterating till j < 8,
then always zeroed@the end of the outer loop - so "j" never
reaching value of 8 - the j == 8 condition is redundant.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9b865f6..0c1cb44 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1128,7 +1128,7 @@ static void dump_message(char *buf, int len)
 		row[j] = buf[i];
 		str[j] = (isprint(buf[i])) ? buf[i] : ' ';
 
-		if ((j == 8) || (i + 1 == len)) {
+		if (i + 1 == len) {
 			for (;j < 8; ++j) {
 				row[j] = 0;
 				str[j] = ' ';


