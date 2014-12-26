From: David Taylor <davidt-lvm2@yadt.co.uk>
Date: Fri, 26 Dec 2014 20:06:32 +0100
Subject: Allow read-only snapshots to be created using liblvm2app
Message-ID: <1419620794-29008-1-git-send-email-davidt-lvm2@yadt.co.uk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I've recently been attempting to use the lvm Python module to script
creation of snapshots for backup purposes.  I'd prefer these to be
read-only snapshots, but the current API doesn't appear to allow this,
either using the Python module or using liblvm2app directly.

I've managed to bodge support for read-only snapshots locally using
the following patches.  I have a couple of reservations about my
approach, but thought I'd send them anyway in the hope of provoking
a better patch!

- By adding a new parameter to the existing lvm_lv_snapshot this
  would break any existing users of liblvm2app, but there appear
  to have been other breaking changes in the recent past.

- A more flexible way to set params for LVs (etc.) would probably
  be more useful, but as this works for my purposes at least,
  I decided to KISS.

David Taylor(2):
  Add readonly parameter to liblvm2app lvm_lv_snapshot()
  Expose readonly parameter of lvm_lv_snapshot() to python bindings.

 liblvm/lvm2app.h | 11 +++++++++--
 liblvm/lvm_lv.c  | 17 ++++++++++++-----
 python/liblvm.c  |  6 ++++--
 3 files changed, 25 insertions(+), 9 deletions(-)

-- 
David Taylor


