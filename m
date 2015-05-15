From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:25 +0000 (UTC)
Subject: master - lvm.8.in: add reference to lvpoll built-in command
Message-ID: <20150515183725.404F360E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf19bbbd5596ea55111678c56087672ee1b72c11
Commit:        bf19bbbd5596ea55111678c56087672ee1b72c11
Parent:        4f1c1f3d6bfa08b554caea0aae5590613c5ef05b
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 13:38:55 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:32:39 2015 +0200

lvm.8.in: add reference to lvpoll built-in command

---
 man/lvm.8.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 28769d2..89b7efe 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -53,6 +53,8 @@ being created in the filesystem for them.
 .TP
 \fBhelp\fP \(em Display the help text.
 .TP
+\fBlvpoll\fP \(em Internal command used by lvmpolld to complete some Logical Volume operations.
+.TP
 \fBpvdata\fP \(em Not implemented in LVM2.
 .TP
 \fBsegtypes\fP \(em Display recognised Logical Volume segment types.


