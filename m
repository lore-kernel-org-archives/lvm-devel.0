From: Eric Ren <renzhengeek@gmail.com>
Date: Thu, 11 Apr 2019 18:01:30 +0800
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
Message-ID: <CAKM4Aex11MbzzGrWE=aYF+KM+_o3cOrs6N2n_T5+tSpuu7J=5Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Another error message is:

" Failed to suspend thin snapshot origin ..."

which is in _lv_create_an_lv():

```
7829         } else if (lv_is_thin_volume(lv)) {
7830                 /* For snapshot, suspend active thin origin first */
7831                 if (origin_lv && lv_is_active(origin_lv) &&
lv_is_thin_volume(origin_lv)) {
7832                         if (!suspend_lv_origin(cmd, origin_lv)) {
7833                                 log_error("Failed to suspend thin
snapshot origin %s/%s.",
7834                                           origin_lv->vg->name,
origin_lv->name);
7835                                 goto revert_new_lv;
7836                         }
7837                         if (!resume_lv_origin(cmd, origin_lv)) { /*
deptree updates thin-pool */
7838                                 log_error("Failed to resume thin
snapshot origin %s/%s.",
7839                                           origin_lv->vg->name,
origin_lv->name);
7840                                 goto revert_new_lv;
7841                         }
7842                         /* At this point remove pool messages,
snapshot is active */
7843                         if (!update_pool_lv(pool_lv, 0)) {
7844                                 stack;
7845                                 goto revert_new_lv;
7846                         }
```

I don't understand why we need to suspend_lv_origin()
and resume_lv_origin() in line?

And, what reasons might cause this errors?

Regards,
Eric




On Thu, 11 Apr 2019 at 08:27, Eric Ren <renzhengeek@gmail.com> wrote:

> Hello list,
>
> Recently, we're exercising our container environment which uses lvm to
> manage thin LVs, meanwhile we found a very strange error to activate the
> thin LV:
>
> ?Aborting.  LV mythinpool_tmeta is now incomplete and '--activationmode
> partial' was not specified.\n: exit status 5: unknown"
>
> centos 7.6
> # lvm version
>   LVM version:     2.02.180(2)-RHEL7 (2018-07-20)
>   Library version: 1.02.149-RHEL7 (2018-07-20)
>   Driver version:  4.35.0
>
> It has appeared several times, but can not be reproduced easily by simple
> steps, and it only errors at that moment, after it happens everything seems
> OK but only that activation failed.
>
> Looking at the code a bit. At first, I suspect the PV may disappear for
> some reason, but the VG sits on only one PV, the setup is simple, the
> environment is only for testing purposes, it seems unlikely the PV has
> problem at that moment and I don't see any problem message with the disk.
>
> ```
>
> 2513         /* FIXME Avoid repeating identical stat in dm_tree_node_add_target_area */
> 2514         for (s = start_area; s < areas; s++) {
> 2515                 if ((seg_type(seg, s) == AREA_PV &&
> 2516                      (!seg_pvseg(seg, s) || !seg_pv(seg, s) || !seg_dev(seg, s) ||
> 2517                        !(name = dev_name(seg_dev(seg, s))) || !*name ||
> 2518                        stat(name, &info) < 0 || !S_ISBLK(info.st_mode))) ||
> 2519                     (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s))) {
> 2520                         if (!seg->lv->vg->cmd->partial_activation) {
> 2521                                 if (!seg->lv->vg->cmd->degraded_activation ||
> 2522                                     !lv_is_raid_type(seg->lv)) {
> 2523                                         log_error("Aborting.  LV %s is now incomplete "
> 2524                                                   "and '--activationmode partial' was not specified.",
> 2525                                                   display_lvname(seg->lv));
> 2526                                         return 0;
>
> ```
> So, does anyone see the same problem? Or any hints to hunt the root cause?
> Any suggestion would be welcome!
>
> Regards,
> Eric
>


-- 
- Eric Ren
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190411/0e3c37a9/attachment.htm>
