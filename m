From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 22 Jan 2010 09:15:29 -0500
Subject: [PATCH 0/3] snapshot-merge related improvements and fixes
Message-ID: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'd appreciate some additional review of these changes.  The first
patch is an "improvement" the other 2 are "fixes".

All tested against the lvm2 testsuite.

Mike Snitzer (3):
  Eliminate extra status ioctls that check open_count in _add_new_lv_to_dtree.
  Check LV's status before sleeping in _wait_for_single_lv.
  Return error if _percent_run is unable to get a percentage.

 lib/activate/dev_manager.c |   62 +++++++++++++++++++++++++++++--------------
 tools/polldaemon.c         |   16 +++++-----
 2 files changed, 50 insertions(+), 28 deletions(-)


