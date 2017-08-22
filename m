From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Aug 2017 14:56:41 +0200
Subject: [PATCHv2 0/2] Stripes options with RAID1
Message-ID: <1503406603-15068-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Marian Csontos (2):
  raid: stripes option is not allowed with RAID1
  tests: Test stripes option with RAID1

 test/shell/lvconvert-raid.sh | 11 +++++++++++
 tools/lvconvert.c            |  5 +++--
 2 files changed, 14 insertions(+), 2 deletions(-)

-- 
1.8.3.1


