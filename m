From: ben <benscott@nwlink.com>
Date: Thu, 12 Jul 2012 21:16:52 -0700
Subject: a pvmove and raid metadata question
Message-ID: <2063714.eEvhsbZ7Nc@laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Having been enlightened about moving the pvs under RAID volumes by specifying 
the legs and not the lv as a whole I did some tests. I noticed that it is 
possible to move the metadata and the image as separate pieces to different 
pvs. Is possibly having the image and the metadata on different devices 
supported or intentional?

Thank you.



