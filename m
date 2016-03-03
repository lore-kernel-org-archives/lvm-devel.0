From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 3 Mar 2016 14:16:31 +0100
Subject: directory instead of link for thinpools?
In-Reply-To: <56D80F3A.4010700@mglug.de>
References: <56D80F3A.4010700@mglug.de>
Message-ID: <56D8392F.5020203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/03/2016 11:17 AM, Oliver Rath wrote:
> This is imho a bit confusing.
> 
> My idea now would be to change the representation of "pool" from a link
> to this (never directly used) device to a directory, which includes the
> links to the pooldevices. Now the representation would look like this
> ("/" is dir, "@" is link):
> 
> /dev/vg/standarddevice@
> /dev/vg/pool/
> /dev/vg/pool/pooldevice@
> 

If your goal is to identify and separate thin LVs based on pools they
belong to, we already have a way to do that easily via -S|--select.

For example:

[0] fedora/~ # lvs -o+layout,role vg
  LV    VG   Attr       LSize  Pool  Data%  Meta%  Layout      Role      
  lvol1 vg   Vwi-a-tz--  4.00m pool1 0.00          thin,sparse public    
  lvol2 vg   Vwi-a-tz--  4.00m pool2 0.00          thin,sparse public    
  lvol3 vg   Vwi-a-tz--  4.00m pool1 0.00          thin,sparse public    
  lvol4 vg   Vwi-a-tz--  4.00m pool2 0.00          thin,sparse public    
  lvol5 vg   Vwi-a-tz--  4.00m pool1 0.00          thin,sparse public    
  lvol6 vg   Vwi-a-tz--  4.00m pool2 0.00          thin,sparse public    
  pool1 vg   twi-aotz-- 52.00m       0.00   1.17   thin,pool   private   
  pool2 vg   twi-aotz-- 24.00m       0.00   1.17   thin,pool   private 


[0] fedora/~ # lvs -o+layout,role vg --select 'pool_lv=pool1'
  LV    VG   Attr       LSize Pool  Data%  Layout      Role      
  lvol1 vg   Vwi-a-tz-- 4.00m pool1 0.00   thin,sparse public    
  lvol3 vg   Vwi-a-tz-- 4.00m pool1 0.00   thin,sparse public    
  lvol5 vg   Vwi-a-tz-- 4.00m pool1 0.00   thin,sparse public    

[0] fedora/~ # lvs -o+layout,role vg --select 'pool_lv=pool2'
  LV    VG   Attr       LSize Pool  Data%  Layout      Role      
  lvol2 vg   Vwi-a-tz-- 4.00m pool2 0.00   thin,sparse public    
  lvol4 vg   Vwi-a-tz-- 4.00m pool2 0.00   thin,sparse public    
  lvol6 vg   Vwi-a-tz-- 4.00m pool2 0.00   thin,sparse public 

Also, we have 'layout' and 'role' fields which make it easier
to identify the LVs in more detail and then you can use that
for your selections (selection on subsets are also supported):

[0] fedora/~ # lvcreate -s vg/lvol6
  Logical volume "lvol7" created.

[0] fedora/~ # lvs -o+layout,role vg --select 'role=snapshot'
  LV    VG   Attr       LSize Pool  Origin FAncestors   Layout      Role                        
  lvol7 vg   Vwi---tz-k 4.00m pool2 lvol6  lvol6        thin,sparse public,snapshot,thinsnapshot

You can even display full path to the device:

[0] fedora/~ # lvs -o+layout,role,path vg --select 'role=snapshot'
  LV    VG   Attr       LSize Pool  Origin FAncestors   Layout      Role                         Path         
  lvol7 vg   Vwi---tz-k 4.00m pool2 lvol6  lvol6        thin,sparse public,snapshot,thinsnapshot /dev/vg/lvol7

You can use selection on any field practically, see also lvs -o help.

I would probably try to avoid editing udev rules because it's
always a source of various problems so we're trying to avoid
changes there as much as possible.

Does that -S|--select make it easier for you to identify the LVs
or do you think it's missing something we could probably enhance
there still?

-- 
Peter


