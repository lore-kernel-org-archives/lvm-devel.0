From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 14 Jan 2008 12:03:50 -0500
Subject: [PATCH 1/11] lvconvert takes '--wait' instead of '--background'
In-Reply-To: <20080114142902.GC8075@agk.fab.redhat.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF3C.8010503@ce.jp.nec.com>
	<20080114142902.GC8075@agk.fab.redhat.com>
Message-ID: <478B95F6.6030302@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Fri, Jan 11, 2008 at 06:43:56PM -0500, Jun'ichi Nomura wrote:
>> Remove '--background' option and add '--wait' option to lvconvert.
>  
>> The option was inherited from pvmove.
>> However, since lvconvert used to exit immediately and it still does
>> for different types of conversion (e.g. linear to mirror conversion),
>> it's more consistent and intuitive to add '--wait' option for foreground
>> polling and do it in background by default.
>  
> I'm not yet persuaded about the need for this change.
> 
> The aim is that the behaviour of the tools be consistent across
> the whole command set.
> 
> Waiting for the operation to complete feels more intuitive to me.

OK. I didn't want to change the existing behavior of lvconvert.
But I agree the synchronous behavior is better choice for default case.

Attached is a patch to fix the inconsistency issue in the other way.
If it looks acceptable, please replace patches "1/11" and "14/14"
with this. Other patches won't be affected.

By default: lvconvert waits for initial sync

  Add a mirror to linear
    # lvs -o+stripes vg/lvol0; lvconvert -m+1 vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert #Str
      lvol0 vg   -wi-a- 1.00G                                          1
      vg/lvol0: Converted: 18.8%
      vg/lvol0: Converted: 39.6%
      vg/lvol0: Converted: 61.7%
      vg/lvol0: Converted: 83.6%
      vg/lvol0: Converted: 100.0%
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog 100.00            2

  Add a mirror to mirror
    # lvs -o+stripes vg/lvol0; lvconvert -m+1 vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog 100.00            2
      vg/lvol0: Converted: 53.7%
      vg/lvol0: Converted: 76.8%
      vg/lvol0: Converted: 99.8%
      vg/lvol0: Converted: 100.0%
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog 100.00            3

  Remove mirror
    # lvs -o+stripes vg/lvol0; lvconvert -m-1 vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog 100.00            3
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog 100.00            2
    # lvs -o+stripes vg/lvol0; lvconvert -m-1 vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog 100.00            2
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert #Str
      lvol0 vg   -wi-a- 1.00G

With background option (-b):

  Add a mirror to linear
    # lvs -o+stripes vg/lvol0; lvconvert -m+1 -b vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert #Str
      lvol0 vg   -wi-a- 1.00G                                          1
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog   0.59            2

  Add a mirror to mirror
    # lvs -o+stripes vg/lvol0; lvconvert -m+1 -b vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog  11.52            2
      LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert           #Str
      lvol0 vg   cwi-a- 1.00G                          0.39 lvol0_mimagetmp_2    2

  Remove mirror
    # lvs -o+stripes vg/lvol0; lvconvert -m-1 -b vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert           #Str
      lvol0 vg   cwi-a- 1.00G                         17.77 lvol0_mimagetmp_2    2
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog  31.45            2
    # lvs -o+stripes vg/lvol0; lvconvert -m-1 -b vg/lvol0; lvs -o+stripes vg/lvol0
      LV    VG   Attr   LSize Origin Snap%  Move Log        Copy%  Convert #Str
      lvol0 vg   mwi-a- 1.00G                    lvol0_mlog  34.57            2
      Logical volume lvol0 converted.
      LV    VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert #Str
      lvol0 vg   -wi-a- 1.00G                                          1

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-wait-for-linear-mirror-conversion.patch
Type: text/x-patch
Size: 2552 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080114/39640b27/attachment.bin>
