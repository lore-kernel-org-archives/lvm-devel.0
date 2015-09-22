From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Sep 2015 13:16:06 +0200
Subject: [PATCHv2 0/4] Fix timeout_list handling
Message-ID: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Two fixes how timeout_list is handled and two [micro] optimizations.

This should address BZ 1210514 and BZ 1220856.

Marian Csontos (4):
  dmeventd: Fix segfault in _timeout_thread
  dmeventd: Fix registration of existing thread
  dmeventd: Remove an useless _lock_mutex
  dmeventd: Allocate new thread only when needed

 daemons/dmeventd/dmeventd.c | 73 ++++++++++++++++++++++++++++-----------------
 1 file changed, 45 insertions(+), 28 deletions(-)

-- 
1.8.3.1


