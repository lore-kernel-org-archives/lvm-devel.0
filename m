From: ben <benscott@nwlink.com>
Date: Mon, 4 Jul 2011 12:59:25 -0700
Subject: lvcreate error message "divisible by 6" bug? LVM version: 2.02.86(2)-cvs
Message-ID: <201107041259.25459.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If I execute the following command I get an error message that doesn't make
sense to me:

lvcreate --name test  --corelog --mirrors 2 --stripes 2 --extents 20 vg0100
 Number of extents requested (20) needs to be divisible by 6

I see why it needs to be divisible by two, so the stripes come out even. But 
why does the number of mirrors matter? I can get to the same place by first 
making a linear volume of 20 extents then adding 2 mirror legs so why can't I 
do it all at once? To me it looks like the <total> number of extents across 
all three mirror legs need to be divisible by 6 but that falls out naturally 
from having each leg a size divisible by two.

  LVM version:     2.02.86(2)-cvs (2011-04-29)
  Library version: 1.02.65-cvs (2011-04-29)
  Driver version:  4.20.0

Thank you.


