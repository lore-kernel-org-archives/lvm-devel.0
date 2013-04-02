From: David Teigland <teigland@redhat.com>
Date: Tue, 2 Apr 2013 17:24:08 -0400
Subject: duplicate pv names
Message-ID: <20130402212408.GA1923@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

My current patch set it having a problem with the test vgimportclone.sh,
which has me questioning the desired pvs output with duplicate pv names.

# dd if=/dev/sdc2 of=/dev/sdc3 bs=256K count=1

# pvs
  Found duplicate PV mPJxALsM0WGwdEZfoE7ewO8inDs1EhyG: using /dev/sdc3 not /dev/sdc2
  PV         VG           Fmt  Attr PSize   PFree  
  /dev/sdc1  vgu          lvm2 a--   32.00g  23.00g
  /dev/sdc3  vgv          lvm2 a--   16.00m  16.00m
  /dev/sdc4  vgv          lvm2 a--   16.00m  16.00m

Do we want to omit /dev/sdc2 from this list?  (Suggest no.)

# pvs -a
  Found duplicate PV mPJxALsM0WGwdEZfoE7ewO8inDs1EhyG: using /dev/sdc3 not /dev/sdc2
  PV                     VG           Fmt  Attr PSize   PFree  
  /dev/sdc1              vgu          lvm2 a--   32.00g  23.00g
  /dev/sdc3              vgv          lvm2 a--   16.00m  16.00m
  /dev/sdc3              vgv          lvm2 a--   16.00m  16.00m
  /dev/sdc4              vgv          lvm2 a--   16.00m  16.00m

Do we want /dev/sdc3 to appear twice, or one of them to be /dev/sdc2, or
omit one like above?  (Suggest both sdc2 and sdc3 appear.)

# pvs /dev/sdc2
  Found duplicate PV mPJxALsM0WGwdEZfoE7ewO8inDs1EhyG: using /dev/sdc3 not /dev/sdc2
  PV         VG   Fmt  Attr PSize  PFree 
  /dev/sdc3  vgv  lvm2 a--  16.00m 16.00m

# pvs /dev/sdc3
  Found duplicate PV mPJxALsM0WGwdEZfoE7ewO8inDs1EhyG: using /dev/sdc2 not /dev/sdc3
  PV         VG   Fmt  Attr PSize  PFree 
  /dev/sdc2  vgv  lvm2 a--  16.00m 16.00m

It seems strange that we use the duplicate that was *not* specified.
Is that what we want?  (Suggest it be reversed.)


