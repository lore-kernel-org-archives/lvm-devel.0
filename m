From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 31 Jan 2013 16:52:30 -0600
Subject: [PATCH 0 of 3]: Improve status (attribute) reporting of RAID LVs via 'lvs'
Message-ID: <1359672750.13305.11.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have a set of three patches that should improve the accuracy of the
'attr' field of 'lvs' when reporting on RAID logical volumes.

1) New lv_raid_dev_health() function:
   Provides a clean interface for RAID to get kernel status
2) Cached lv_raid_dev_health results:
   A suggested optimization, but isn't necessary.
3) Improved attribute reporting of RAID LVs via 'lvs'
   Fixes bz903249 and other complaints

 brassow


