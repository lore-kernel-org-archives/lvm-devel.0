From: Jeff Chua <jeff.chua.linux@gmail.com>
Date: Fri, 13 Aug 2010 18:02:06 -0000
Subject: linux-2.6.35+ causes LVM to fail with " device-mapper: version ioctl failed: Inappropriate ioctl for device"
Message-ID: <AANLkTime9NS3Bk-8ZpovRNy9iEGJxwYw=-aZ38JoRa_3@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It seems one of these commits in
8357422d4bf33bc2c35884d4016c3fc9efbbc1d2 is causing LVM2
(LVM2.2.02.72) to fail.

Previously good logical volumes cannot be mounted anymore, and new one
cannot be created. All failed with the error ...

"device-mapper: version ioctl failed: Inappropriate ioctl for device"


Is there a new LVM2 for this new dm ioctl or the dm is not right?


Thanks,
Jeff.


