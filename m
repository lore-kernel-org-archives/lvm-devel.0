From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 26 Feb 2010 17:35:27 -0600
Subject: [PATCH 0 of 10] LVM introduce 'mirrored' log type
Message-ID: <1267227327.22223.5.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patches are the result of integrating agk's allocation changes.  I
think I'd still like to clean them up a little, but they are usable.
I'm going to run them through my test script to test all the various
device failures before submitting for final review.  In the mean time,
I'd appreciate any comments on the patches, especially:
[PATCH 5 of 10] LVM:  hack to make things work

thanks,
 brassow

[I will also begin again to try to work so that only top-level LVs are
passed to 'lvconvert --repair'.  To show things are working, however,
the final patch simply removes the restriction in lvconvert for now.]


