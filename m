From: ben <benscott@nwlink.com>
Date: Tue, 02 Oct 2012 17:28:42 -0700
Subject: Inconsistent flags of thin volumes and snapshots
Message-ID: <1540614.udHforCSB6@laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have noticed inconsistencies in the flags with regard to
thin volumes. I haven't posted them as bugs yet though because I
am not sure if some are intentional.

The first column of the flags is 'o' when a normal snapshot is taken
of a thin volume but is 'V' when a thin snap is used. I haven't
checked to see if 'O' is used for merging with thin snapshots.

The other issue I have run into is that a thin snapshot doesn't
put an 's' into column 1 or column 7. This makes parsing more
difficult since a thin volume and thin snap look the same in the
flags. It seems that one of the columns could be changed to
an 's' without losing any information. The first column also is
used for merging 'S' so that would probably be the best one.

~# lvs
  LV        VG      Attr      LSize   Pool     Origin    Data%  
  Pool_One  MyGroup twi-a-tz-   1.00g                      9.96
  fat_snap1 MyGroup swi-a-s-- 112.00m          thin_vol2   0.00
  thin_vol2 MyGroup owi-a-tz-   2.00g Pool_One             4.98


~# lvs
  LV         VG      Attr      LSize Pool     Origin    Data%   
  Pool_One   MyGroup twi-a-tz- 1.00g                      9.96
  thin_snap1 MyGroup Vwi-a-tz- 2.00g Pool_One thin_vol2   4.98
  thin_vol2  MyGroup Vwi-a-tz- 2.00g Pool_One             4.98


Should I post these as bugs?

Thank you.





