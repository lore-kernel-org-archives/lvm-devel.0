From: Guangliang Zhao <gzhao@suse.com>
Date: Mon, 17 Dec 2012 20:44:22 +0800
Subject: [PATCH 0/2] make mirror legs on different tag pvs
Message-ID: <1355748264-17077-1-git-send-email-gzhao@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

With these patches, the mirror legs could be placed on
the PVs(with different tags) from the other legs.

Guangliang Zhao (2):
  mirror: make mirror legs on different tag pvs
  mirror: improve mirror legs on different tag pvs

 doc/example.conf.in     |   17 ++++++++++++++
 lib/config/defaults.h   |    1 +
 lib/metadata/lv_manip.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in       |    3 +++
 4 files changed, 77 insertions(+)

-- 
1.7.10.4


