From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 25 Apr 2007 00:28:58 -0400
Subject: [patch 0/4] Update pvck to include label and metadata record detection
Message-ID: <20070425042858.836940000@redhat.com>>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following patches add LVM label and metadata detection to
pvck.  A few of these are reposts of previous patches, for
completeness.  Should apply cleanly on top of CVS.

Patches are as follows:
1) lvm2-add-generalised-count-hyphes.patch: repost of
https://www.redhat.com/archives/lvm-devel/2007-April/msg00016.html
2) lvm2-add-pvck-label-scan.patch: repost of
https://www.redhat.com/archives/lvm-devel/2007-April/msg00017.html
3) lvm2-add-config-section-support-functions.patch: updated repost of
https://www.redhat.com/archives/lvm-devel/2007-April/msg00002.html
4) lvm2-add-pvck-metadata-scan.patch: New patch which adds metadata
record scanning.



--


