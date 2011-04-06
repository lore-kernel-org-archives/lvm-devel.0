From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 06 Apr 2011 18:51:40 +0900
Subject: snapshot in shared disk environment
In-Reply-To: <20110405180854.GI4849@agk-dp.fab.redhat.com>
References: <4D9AED98.1080900@ce.jp.nec.com>
	<20110405174556.GH4849@agk-dp.fab.redhat.com>
	<20110405180854.GI4849@agk-dp.fab.redhat.com>
Message-ID: <4D9C37AC.50801@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks for comments, Mike and Alasdair,

On 04/06/11 00:56, Mike Snitzer wrote:
> Jon Brassow has worked on exclussive activation that allows snapshots to
> be activated on a specific machine.  Please see lvm2.git commit
> 1ce9f8621bce7baa815145b7de8bd3ffca14420a

Thanks for the pointer.
It allows one node to exclusively access both snapshots and origin.
So we still cannot activate snapshot while origin is shared.

On 04/06/11 03:08, Alasdair G Kergon wrote:
> On Tue, Apr 05, 2011 at 06:45:56PM +0100, Alasdair G Kergon wrote:
>> If we enforce a read only origin, we can support selective snapshot activation.
>> The tools will need some changes though to do this.
>  
> So activate/deactivate origin would work exactly as now, ensuring all
> snapshots are active.
> 
> Additionally, we would allow activation/deactivation of individual snapshots
> while the origin is read-only.

Right.

Attached is a very naive patch.
It only works for deactivating individual snapshot.

  # lvcreate -l1 -ntemplate1 localvg
  <initialize contents of localvg/template1>
  # lvchange -pr localvg/template1
  # lvcreate -s -l1 -nvmdisk1 localvg/template1
  # lvcreate -s -l1 -nvmdisk2 localvg/template1
  # lvchange -an localvg/vmdisk2
  # lvs
    LV         VG             Attr   LSize  Origin     Snap%
    template1  localvg        ori-a-  4.00m
    vmdisk1    localvg        swi-a-  4.00m template1  0.20
    vmdisk2    localvg        swi---  4.00m template1

Activation and monitoring code needs additional change.

  # lvchange -ay localvg/vmdisk2
    Couldn't find snapshot origin uuid LVM-7hdf40g8Lx4njV1skk2f2mWsnbAM2ZHcCNz0USZHedmev63nzo0uQCJPl7OJwJF9-real.

  # lvchange -an localvg/template1
    _get_device_info: device not found
    _get_device_info: device not found
    localvg/snapshot1: snapshot segment monitoring function failed.
  # lvs
    LV         VG             Attr   LSize  Origin    Snap%
    template1  localvg        ori---  4.00m
    vmdisk1    localvg        swi---  4.00m template1
    vmdisk2    localvg        swi---  4.00m template1

-- 
Jun'ichi Nomura, NEC Corporation


--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -533,6 +533,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)) &&
+	    (origin_from_cow(lv)->status & LVM_WRITE) &&
 	    arg_count(cmd, available_ARG)) {
 		log_error("Can't change snapshot logical volume \"%s\"",
 			  lv->name);


