From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 12 Dec 2006 17:54:39 -0500
Subject: [PATCH LVM2] Prefer small areas if possible
Message-ID: <457F332F.7080401@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes the mismatch between the code and the comment
regarding the preference of the smaller area possible.


Comment in the code suggests choosing the smallest possible PE
to satisfy the request, which sounds reasonable.
However, the "goto next_pv" at the end prevents it to happen:
if PV with the sufficient area is found, don't search the PV further.
(Note that PV area in the PV is sorted by size.)

The comment is this (In lib/metadata/lv_manip.c:_find_parallel_space()):
   /*
    * Put the smallest area of each PV that is at least the
    * size we need into areas array.  If there isn't one
    * that fits completely and we're allowed more than one
    * LV segment, then take the largest remaining instead.
    */

The logic was:
  foreach pv {
     foreach pv_area { # pv_area is sorted by size (large to small)
        if the pv_area is smaller than requested {
           if there is already one candidate found in this pv {
              use the candidate and goto next pv
              <i.e. the smallest possible area is chosen>
           } else if split is allowed {
              # at this point, there was no area fits completely
              select the pv_area as a candidate
              goto next pv_area
              <i.e. the largest area is chosen>
           } else
              no candidate from this pv, goto next pv
        } else {
           select the pv_area as a candidate
           goto next pv
        }
     }
  }
and the patch removes the goto at the end.


Patch applicable to LVM2 2.02.16.

Shell script to reproduce the problem and the sample metadata
is attached for reference.
You can reproduce the problem with just executing the script
without additional parameters.
Also, additional test scripts are included.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: prefer_smaller_pe.patch
Type: text/x-patch
Size: 1157 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/0a1c93cd/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-prefer-smaller-area.sh
Type: application/x-sh
Size: 1680 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/0a1c93cd/attachment.sh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm2-prefer-smaller-area.vg
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/0a1c93cd/attachment.ksh>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-prefer-smaller-area-appendix1.sh
Type: application/x-sh
Size: 2343 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/0a1c93cd/attachment-0001.sh>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-prefer-smaller-area-appendix2.sh
Type: application/x-sh
Size: 3115 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/0a1c93cd/attachment-0002.sh>
