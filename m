From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 28 Jul 2010 23:43:58 -0400
Subject: Handle transient errors for mirrored log in lvconvert --repair
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228865AB@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

I would like to continue a discussion about how to handle transient error
for mirrored log.

[lvm-devel] [PATCH] handle transient errors in lvconvert --repair
https://www.redhat.com/archives/lvm-devel/2010-May/msg00173.html

> _lvconvert_mirrors_repair()
> ...
>         lv_check_transient(lv); /* TODO check this in lib for all commands? */
> 
> -       if (!(lv->status & PARTIAL_LV)) {
> +       log_lv = first_seg(lv)->log_lv;
> +       if (log_lv && log_lv->status & MIRRORED)
> +               lv_check_transient(log_lv);
> +
> +       if (!(lv->status & PARTIAL_LV) && !log_lv &&
> +           !(log_lv->status & PARTIAL_LV)) {
> ...
>         new_log_count = old_log_count;
> -       log_lv = first_seg(lv)->log_lv;
>         if (log_lv) {

As shown above, I hope this kind of code to be added to check the status
of a log volume.

I understand your concern that this doesn't cover all cases. For example,
there might be a problem when mirror_{log|mirror}_fault_policy is set
to 'allocate' instead of 'removed.'

lv_check_transient() marks logical volumes as PARTIAL_LV based on the status
reported by kernel, but it doesn't mark physical volumes which are a part of
partial logical volumes. This means that a mirror volume is repaired by
removing partial volumes, but physical devices, which were a part of the
partial volumes, could be re-allocated for a mirror leg or a mirror log later.
The re-allocation may be a problem if the repair was triggered by medium errors.

Here is a discussion. We can rescue a case that 'removed' policy is set to
mirror_{log|mirror}_fault_policy by adding lv_check_transient() for a mirrored
log volume, while application will hang up when a transient error or medium
error occurred on mirrored log without this patch.

How about adding the patch for a short term solution to save in the case of
'removed' policy? We have already made a decision when the first patch is
committed.

https://www.redhat.com/archives/lvm-devel/2010-May/msg00217.html

If the patch makes something worse, I agree that we need to fix it or find
a better solution, but one of the most important functions of mirroring is
to let system running even though one of mirror legs or log broke. I believe
that the patch helps to achieve it. I agree that 'allocate' is an important
policy, but I would be grad if 'remove' policy works well at first.

I appreciate your comments.

Thanks,
Taka


