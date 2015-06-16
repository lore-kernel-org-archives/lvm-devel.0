From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 19:24:50 +0000 (UTC)
Subject: master - man lvm: mention hyphens in option names
Message-ID: <20150616192450.14DF760DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=857296c8236f12d93029d6382c8d472598666e6e
Commit:        857296c8236f12d93029d6382c8d472598666e6e
Parent:        d5adec105626c39ffd6295c832dfda9189a1d85d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 10:33:01 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 10:33:01 2015 -0500

man lvm: mention hyphens in option names

---
 man/lvm.8.in |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 89b7efe..b8b4854 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -163,6 +163,10 @@ The following commands are not implemented in LVM2 but might be in the future: l
 The following options are available for many of the commands.
 They are implemented generically and documented here rather
 than repeated on individual manual pages.
+
+Additional hyphens within option names are ignored.  For example,
+\-\-readonly and \-\-read\-only are both accepted.
+
 .TP
 .BR \-h ", " \-? ", " \-\-help
 Display the help text.


