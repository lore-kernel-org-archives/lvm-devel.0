From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:55:39 +0100
Subject: [PATCH 0/6] Minor fixes and updates
Message-ID: <cover.1265812946.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Set of miscelaneous updates and fixes awaiting some review 
- especially the last patch

Zdenek Kabelac (6):
  Cleanup gcc warning: function declaration isn't a prototype
  Cleanup gcc const warning
  Clean gcc const warning
  Cleanup float arithmetic gcc warning
  Fix report_uint64
  Fix compiler warning about strict-aliasing break

 lib/device/device.c  |   18 +++++++++---------
 lib/report/report.c  |   12 ++++++------
 libdm/libdm-report.c |   12 ++++++------
 tools/lvmcmdline.c   |    2 +-
 4 files changed, 22 insertions(+), 22 deletions(-)


