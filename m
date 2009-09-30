From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 30 Sep 2009 19:08:08 -0400
Subject: [PATCH v2 0/2] Eliminate floating-point comparisions
Message-ID: <1254352090-23243-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset cleans up LVM2 to use well defined states for comparisions
rather than rely on floating point comparisions.

This was done as part of the LVM2 snapshot-merge work.

v2: adjusts the patches to apply to the latest 2.02.54-cvs; but an
    enumerated type hasn't been introduced in the first patch...


