From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 18 Feb 2010 20:41:21 -0500
Subject: [PATCH 8 of 13] LVM: add logic to allow mirrored log
In-Reply-To: <201002171756.o1HHuw4H004907@hydrogen.msp.redhat.com>
References: <201002171756.o1HHuw4H004907@hydrogen.msp.redhat.com>
Message-ID: <4B7DEC41.4080006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/17/10 12:56, Jonathan Brassow wrote:
>  /*
> @@ -798,9 +840,15 @@ static int _lvconvert_mirrors(struct cmd
>  			return_0;
>  		lp->pvh = lp->failed_pvs = failed_pvs;
>  		log_lv = first_seg(lv)->log_lv;
> -		if (!log_lv || log_lv->status & PARTIAL_LV) {
> +		if (!log_lv) {
>  			failed_log = 1;
>  			log_count = 0;
> +		} else {
> +			log_count = lv_mirror_count(log_lv);
> +			if (log_lv->status & PARTIAL_LV) {
> +				failed_log = 1;
> +				log_count -= _failed_mirrors_count(log_lv);
> +			}

When log is a "disk" type log and log disk failed, lvconvert --repair
vg00/lv00 doesn't work. In this case, _failed_mirrors_count() returns
"-1" and log_count became "2." (should be "0") I think that we need to
check if its return value is negative.

    if (_failed_mirrors_count(log_lv) < 0)
        log_count = 0;
    else
        log_count -= _failed_mirrors_count(log_lv);


Here is the reproduction steps.

1. create mirror volume with disk log

# lvcreate -m1 -L12m -nlv00 --mirrorlog disk vg00
  Logical volume "lv00" created

2. disable log device

# echo offline > /sys/block/sde/device/state  /* sde is a log device */

3. kill dmeventd

4. Write data

# dd if=/dev/zero of=/dev/vg00/lv00 bs=4096 count=1
<no response>

5. execute lvconvert command.

# lvconvert --config 'devices{ignore_suspended_devices=1}' --repair --use-policies vg00/lv00
  Couldn't find device with uuid 'CAteli-tCjh-3zZ3-yEjl-mcLX-uVff-aRDh7b'.
  Couldn't find device with uuid 'CAteli-tCjh-3zZ3-yEjl-mcLX-uVff-aRDh7b'.
  Mirror status: 0 of 2 images failed.

  Adding log redundancy not supported yet.
  Try converting the log to 'core' first.

Thanks,
Taka


