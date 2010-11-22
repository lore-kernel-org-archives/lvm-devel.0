From: ben <benscott@nwlink.com>
Date: Mon, 22 Nov 2010 15:03:25 -0800
Subject: wishlist: Two lvm2app pv and lv properties still needed
In-Reply-To: <20101122213948.11757.qmail@sourceware.org>
References: <20101122213948.11757.qmail@sourceware.org>
Message-ID: <201011221503.26030.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When using lvm2app function calls to retrieve physical volume segment 
properties there seems to be no way the get the "lv_name" to tie each segment 
of the pv to an lv. For instance like this:

pvs --segments -o+lv_name
  PV         VG    Fmt  Attr PSize   PFree   Start SSize LV   
  /dev/sdh1  local lvm2 a-   768.00m 512.00m     0     1      
  /dev/sdh1  local lvm2 a-   768.00m 512.00m     1     1 lvol1
  /dev/sdh1  local lvm2 a-   768.00m 512.00m     2     1      
  /dev/sdi1  local lvm2 a-   768.00m      0      0     3 lvol2

The same seems to apply to getting lv segments properties and their 
asscociated devices.   Like this:

 lvs -o+devices
  LV    VG    Attr   LSize    Devices
  lvol1 local -wi-a- 256.00m  /dev/sdh1(1)
  lvol2 local -wi-a- 768.00m  /dev/sdi1(0)

It would be great if those two things, esp. the second one could be 
implemented. 

Thank you

ben <benscott@nwlink.com>


