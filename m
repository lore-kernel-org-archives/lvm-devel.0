From: ben <benscott@nwlink.com>
Date: Sat, 9 Jul 2011 22:28:44 -0700
Subject: lvm2 2.02.86 error... udev problem?
Message-ID: <201107092228.44493.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I just downloaded and compiled lvm2 2.02.86 and have seen the following error 
message several times:

~/# lvcreate --name test --mirrors 1 --size 1g vg01
  /dev/mapper/vg01-test_mimage_0: open failed: No such file or directory
  /dev/mapper/vg01-test: open failed: No such file or directory
  /dev/vg01/test: not found: device not cleared
  Aborting. Failed to wipe start of new LV.
  LV vg01/test in use: not deactivating
  Unable to deactivate failed new LV. Manual intervention required.

The volume is created despite the error message. Is this another udev issue? I 
am running Debian Sid and udev 171-2.


