From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 23 Apr 2010 17:11:16 -0400
Subject: rebased LVM2 multisnap patches
Message-ID: <20100423211115.GA22031@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Please see:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.64/

Various small fixes were needed to cope with the latest LVM2 changes.
As the top of the series file states:
Tested to apply (and work) on: lvm2.git commit d5857e6d48 (pre 2.02.64)

All lvm2 testsuite tests pass using both locking_type 1 and 3.
Tested against r19 of the DM multisnap patches on 2.6.34-rc5.

The few multisnap tests I run work... adding real multisnap tests
to the testsuite is still needed.

Mike


