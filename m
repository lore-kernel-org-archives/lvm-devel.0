From: Oliver Rath <rath@mglug.de>
Date: Fri, 30 Aug 2013 15:24:48 +0200
Subject: "semop failed" while lvrename execution
Message-ID: <52209D20.8090701@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

im using here ubuntu 12.04.03 with lvm-git with ( --with-thin=internel
--enable-udev_sync --enable-udev_rules

Now following occurs:

root at asterisk:dmiadm# lvcreate --name udevtest -V 50M -T
dmivg/winthinpool  Rounding up size to full physical extent 52,00 MiB
  Logical volume "udevtest" created
  semid 65536: semop failed for cookie 0xd4d1ce4: incorrect semaphore state
  Failed to set a proper state for notification semaphore identified by
cookie value 223157476 (0xd4d1ce4) to initialize waiting for incoming
notifications.
root at asterisk:dmiadm# lvrename /dev/dmivg/udevtest udevtest-renamed
  Renamed "udevtest" to "udevtest-renamed" in volume group "dmivg"
  semid 98304: semop failed for cookie 0xd4d54d2: incorrect semaphore state
  Failed to set a proper state for notification semaphore identified by
cookie value 223171794 (0xd4d54d2) to initialize waiting for incoming
notifications.
root at asterisk:dmiadm# ls -l /dev/dmivg/udevtest-renamed
lrwxrwxrwx 1 root root 8 Aug 30 15:17 /dev/dmivg/udevtest-renamed ->
../dm-56
root at asterisk:dmiadm# ls -l /dev/mapper/dmivg-udevtest--renamed
lrwxrwxrwx 1 root root 8 Aug 30 15:17 /dev/mapper/dmivg-udevtest--renamed



Furthermore, _deleting the lv shows:

# lvremove /dev/dmivg/udevtest-renamed
Do you really want to remove active logical volume udevtest-renamed?
[y/n]: y
  Logical volume "udevtest-renamed" successfully removed
  semid 131072: semop failed for cookie 0xd4d2f12: incorrect semaphore state
  Failed to set a proper state for notification semaphore identified by
cookie value 223162130 (0xd4d2f12) to initialize waiting for incoming
notifications.


What is todo?

Tfh!

Oliver


