From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 10 Jan 2008 18:40:21 +0000
Subject: [PATCH lvconvert 0/11] Additional fixes and changes to lvconvert restructure
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <20080110184021.GP3510@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 04, 2008 at 09:55:20AM -0500, Jun'ichi Nomura wrote:
> Bug fixes
> [ 1/11] Correct 'const' for _lv_mimage_in_sync()
> [ 2/11] Don't start polldaemon if conversion failed in early stage
> [ 3/11] Multiple fixes about to-corelog conversion
> [ 4/11] Fix possible mirror image corruption 
> [ 5/11] Don't insert temporary layer for corelog mirror
> [ 6/11] init_mirror_in_sync(0) for corelog mirror addition
> [ 7/11] Fix semantic consistency of mirrorlog option
> 
> Feature updates
> [ 8/11] Add internal 'CONVERTING' flag for LVs under conversion
> [ 9/11] Add a new attr field char for the CONVERTING LV
> [10/11] Warn if lvconvert needs activation to complete conversion

Not sure here - should we perform the activation immediately?

> [11/11] Start lvconvert polldaemon on activation (like pvmove)
 
All applied, thanks.

Alasdair
-- 
agk at redhat.com


