From: ben <benscott@nwlink.com>
Date: Mon, 9 May 2011 20:42:21 -0700
Subject: lvm2app lv properties stripe size issue
Message-ID: <201105092042.22143.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When using:

   value = lvm_lvseg_get_property(lvm_lvseg, "stripesize");

The value returned seems to be double what I expect. Is this function 
returning disk sectors (512 bytes) and not 1024 byte units?

Thank you.

 


