From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:49 +0000 (UTC)
Subject: master - man: cleanup new params
Message-ID: <20140408090249.48D6860268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db4cf3010640307d1764cebf2c7497676d209383
Commit:        db4cf3010640307d1764cebf2c7497676d209383
Parent:        2868d897da186d0f65856936543e25bcd5057440
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 22:20:27 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:14 2014 +0200

man: cleanup new params

Correcting cachemode args
---
 man/lvcreate.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 445af80..4e7612a 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -150,7 +150,7 @@ Controls whether Logical Volumes are persistently flagged to be skipped during
 activation. By default, thin snapshot volumes are flagged for activation skip.
 To activate such volumes, an extra \fB\-K/\-\-ignoreactivationskip\fP option must
 be used. The flag is not applied during deactivation.
-Use \fBlvchange \-k/\-\-setactivationskip {y | n}\fP command to attach or
+Use \fBlvchange \-k/\-\-setactivationskip {y|n}\fP command to attach or
 detach the flag for existing volumes. To see whether the flag is attached,
 use \fBlvs\fP command where the state of the flag is reported within
 \fBlv_attr\fP bits.
@@ -159,7 +159,7 @@ use \fBlvs\fP command where the state of the flag is reported within
 Ignore the flag to skip Logical Volumes during activation.
 
 .TP
-.IR \fB\-\-cachemode " " { writeback | writethrough }
+.IR \fB\-\-cachemode " {" writeback | writethrough }
 Specifying a cache mode determines when the writes to a cache LV
 are considered complete.  When \fIwriteback\fP is specified, a write is
 considered complete as soon as it is stored in the cache pool LV.


