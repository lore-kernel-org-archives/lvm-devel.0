From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Oct 2010 16:28:19 +0200
Subject: [PATCH 0/2] Strict aliasing
Message-ID: <cover.1287584556.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch goes with test that executes partition scanning code path
(so improves our coverage a bit)

Looks like are command line --config options has some room
for improvements as I had to change the global config.


Zdenek Kabelac (2):
  Fix compiler warning about strict-aliasing break
  Testcase for partition table scanning

 lib/device/device.c      |   18 +++++++++---------
 test/t-test-partition.sh |   30 ++++++++++++++++++++++++++++++
 test/test-utils.sh       |    1 +
 3 files changed, 40 insertions(+), 9 deletions(-)
 create mode 100755 test/t-test-partition.sh

-- 
1.7.3.1


