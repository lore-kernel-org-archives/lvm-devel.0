From: Brassow Jonathan <jbrassow@redhat.com>
Date: Tue, 6 Sep 2016 09:36:05 -0500
Subject: [PATCH] man page clarification - Bug 1372089
Message-ID: <81F46EF5-A385-447C-A5DB-32F3B2F90B52@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make sure that people know that non-zero exit codes cannot be relied on
for specific meaning in LVM.  (https://bugzilla.redhat.com/1372089)

Index: Work/lvm2/man/lvm.8.in
===================================================================
--- Work.orig/lvm2/man/lvm.8.in
+++ Work/lvm2/man/lvm.8.in
@@ -744,6 +744,8 @@ without % suffix), string.
 .SH DIAGNOSTICS
 .
 All tools return a status code of zero on success or non-zero on failure.
+Non-zero exit codes may change and should not be assumed to imply specific
+errors.
 .
 .SH ENVIRONMENT VARIABLES
 .


