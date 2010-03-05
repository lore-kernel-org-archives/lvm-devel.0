From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 05 Mar 2010 17:57:42 -0600
Subject: [PATCH 0 of 10] LVM: mirrored log patches
Message-ID: <1267833465.10315.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There will likely be at least one more round of these patches - mostly
to clean-up the last patch I've been working on.

This round includes changes to the _lvconvert_mirrors function to allow
it to handle the repair conversions necessary for 'lvconvert' to accept
only top-level LVs.  It also includes suggested changes from Taka
(thanks for those!).

 brassow


