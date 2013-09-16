From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 16 Sep 2013 15:41:55 -0400 (EDT)
Subject: ANNOUNCE: remove device on close
Message-ID: <alpine.LRH.2.02.1309161535340.9077@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I placed the patches for deferred removal at 
http://people.redhat.com/mpatocka/patches/kernel/deferred-remove/

Use the command:
dmsetup remove --deferred <device_name>

If the device is closed, it is deleted as usual. If the device is open, it 
is flagged to be deleted on close. When the last process that keeps the 
device open closes it, the device is deleted.

The state of deferred-remove flag can be queried with dmstup info - there 
is "(DEFERRED REMOVE)" if the device is flagged to be deleted.

The request to delete a device can be cancelled with message:
dmsetup message <device_name> 0 @cancel_deferred_remove

Mikulas


