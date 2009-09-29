From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 10:56:40 -0400
Subject: [PATCH 0/2] Eliminate floating-point comparisions
Message-ID: <1254236202-30381-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset depends on depends on DM returning 0 when finished, e.g.:
https://www.redhat.com/archives/dm-devel/2009-September/msg00253.html

It cleans up LVM2 to use well defined states for comparisions rather
than rely on floating point comparisions.

This was done as part of the LVM2 snapshot-merge work.


