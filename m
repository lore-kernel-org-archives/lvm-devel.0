From: Hannes Reinecke <hare@suse.de>
Date: Tue, 18 Mar 2014 09:24:00 +0100
Subject: [PATCH 0/2] Ancient SUSE patches
Message-ID: <1395131042-5015-1-git-send-email-hare@suse.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

here are two ancient SUSE patches which for some reason never
got sent upstream.

Thomas Fehr (1):
  Fix pvdisplay to refer to sectors, not KB

Xinwei Hu (1):
  Handle duplicate PVs on drbd

 lib/cache/lvmcache.c | 14 ++++++++++++++
 man/pvdisplay.8.in   |  2 +-
 2 files changed, 15 insertions(+), 1 deletion(-)

-- 
1.8.1.4


