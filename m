From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 16:38:02 +0000 (UTC)
Subject: master - man lvm: add section about unique VG names
Message-ID: <20151202163802.79D2560DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bbf89e9ec92388cbfa722c0fbb6ff3fad0232aa
Commit:        3bbf89e9ec92388cbfa722c0fbb6ff3fad0232aa
Parent:        61573bd1972702f1066c3df5543acc47e9e35da8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 2 10:37:25 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 2 10:37:25 2015 -0600

man lvm: add section about unique VG names

---
 man/lvm.8.in |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 31f7187..4e9e1dd 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -502,6 +502,28 @@ amendment when the software is updated.  Should you need to process the node
 names in /dev/mapper, you may use \fBdmsetup splitname\fP to separate out the
 original VG, LV and internal layer names.
 .
+.SH UNIQUE NAMES
+.
+
+VG names should be unique.  vgcreate will produce an error if the
+specified VG name matches an existing VG name.  However, there are cases
+where different VGs with the same name can appear to LVM, e.g. after
+moving disks or changing filters.
+
+When VGs with the same name exist, commands operating on all VGs will
+include all of the VGs with the same name.  If the ambiguous VG name is
+specified on the command line, the command will produce an error.  The
+error states that multiple VGs exist with the specified name.  To process
+one of the VGs specifically, the --select option should be used with the
+UUID of the intended VG: '--select vg_uuid=<uuid>'.
+
+An exception is if all but one of the VGs with the shared name is foreign
+(see
+.BR lvmsystemid (7).)
+In this case, the one VG that is not foreign is assumed to be the intended
+VG and is processed.
+
+.
 .SH ALLOCATION
 .
 When an operation needs to allocate Physical Extents for one or more


