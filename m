From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  7 Sep 2016 00:58:05 +0000 (UTC)
Subject: master - man: Additional info on exit statuses.
Message-ID: <20160907005805.E76BA60E4B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6bcdbe13c25af3cf4bfd0849342fff5ffd75700
Commit:        a6bcdbe13c25af3cf4bfd0849342fff5ffd75700
Parent:        a54f073af838b611d7099597919f69c24cffea07
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 7 01:57:09 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 7 01:57:09 2016 +0100

man: Additional info on exit statuses.

---
 man/lvm.8.in |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index da85349..0db0ee4 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -744,6 +744,11 @@ without % suffix), string.
 .SH DIAGNOSTICS
 .
 All tools return a status code of zero on success or non-zero on failure.
+The non-zero codes distinguish only between the broad categories of
+unrecognised commands, problems processing the command line arguments
+and any other failures.  As LVM remains under active development, the
+code used in a specific case occasionally changes between releases.
+Message text may also change.
 .
 .SH ENVIRONMENT VARIABLES
 .


