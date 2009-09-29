From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 11:22:53 -0400
Subject: [PATCH 0/4] Clean-up polldaemon to be more generic to allow re-use
Message-ID: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The polldaemon will be re-used for LVM2's snapshot-merge support.

This patchset provides the cleanup patches that a couple snapshot-merge
specific follow-on patches depend on.

NOTE: the 2/4 patch is provided as a separate patch for review purposes;
but in practice when it is committed it should be combined with the
3/4 patch to avoid reduced functionality (progress_display) if one were
to bisect.


