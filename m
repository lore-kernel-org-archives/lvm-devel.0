From: Petr Rockai <prockai@redhat.com>
Date: Fri, 11 Jul 2008 15:42:15 +0200
Subject: [PATCH] (1/3) partial volume group metadata handling (take 2)
Message-ID: <87zloo1qrs.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

further cleanups amassed to the patchset:
- PARTIAL_VG is now never set on live metadata
- use vg_missing_pv_count instead of PARTIAL_VG check to see if PVs are missing
- COW LVs (in snapshots) are marked PARTIAL_LV when origin is missing, instead
  of the virtual (snapshotN) LV
- MISSING_PV uses the new compatible flags mechanism

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lib-partial_metadata.diff
Type: text/x-diff
Size: 19448 bytes
Desc: lib-partial_metadata.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080711/a48824e1/attachment.bin>
-------------- next part --------------

Yours,
    Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
