From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 May 2015 15:45:06 +0000 (UTC)
Subject: master - man: missed y|n for wipesignatures
Message-ID: <20150515154506.0973160CDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03aec36fc05c7cd78e0a5407c09e4d47b973c02f
Commit:        03aec36fc05c7cd78e0a5407c09e4d47b973c02f
Parent:        a98ceceb1d101f0b19a6115f406e23f13feab5ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 17:43:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 15 17:44:52 2015 +0200

man: missed y|n for wipesignatures

---
 man/lvcreate.8.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index de4f168..5f5f74b 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -91,7 +91,8 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-v | \-\-verbose ]
-.RB [ \-W | \-\-wipesignatures ]
+.RB [ \-W | \-\-wipesignatures
+.RI { y | n }]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
 .RI [ VolumeGroup { Name | Path }


