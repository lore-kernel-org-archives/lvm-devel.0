From: Leo Yan <leo.yan@linaro.org>
Date: Wed, 24 Feb 2021 11:16:30 +0800
Subject: Question: the failure handling for sanlock
In-Reply-To: <20210215163127.GA25608@redhat.com>
References: <20210214101303.GA399193@leoy-ThinkPad-X240s>
	<20210215163127.GA25608@redhat.com>
Message-ID: <20210224031630.GB25715@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

On Mon, Feb 15, 2021 at 10:31:27AM -0600, David Teigland wrote:

[...]

> We only need to forcefully deactivate LVs in the failed VG.  The lvmlockd
> man page section "sanlock lease storage failure" describes how this
> process can work manually, and mentions doing it automatically in the
> future.  In the manual process you'd try to stop applications using the
> fs, unmount file systems on the LVs, then try to deactivate the LVs.
> Since there are storage issues, the unmount and deactivate might hang, in
> which case you could try dmsetup wipe_table on the LVs.  You might just
> skip immediately to that last step since there's not a lot of time.
> 
> There was a script written in 2017 to automate that final dmsetup step.
> It was finished or very close, but I don't remember what kept us from
> including it.  An idea to make dmsetup do more of the work perhaps left us
> unsure what to do.  Here is the script and some discussion:
> https://listman.redhat.com/archives/lvm-devel/2017-September/msg00011.html
> 
> There was also a small lvmlockctl patch to replace the
> run_strong_blkdeactivate() comment with running the script.
> 
> If you can get this to work for your case I'd like to get it included in
> lvm.

I verified the two patches you mentioned, and applied your suggestion
to use the command:

  "$DMSETUP" info -c -S "uuid=~LVM && vgname=$VG_NAME && lv_layer=\"\"" \
  	-o name --noheadings | xargs "$DMSETUP" wipe_table

At the end, I can see the device is changed to use DM "error" backend
driver:

  Broadcast message from systemd-journald at localhost.localdomain (Tue 2021-02-23 21:55:16 EST):
  lvmlockctl[2032]: Deactivated LVs in VG TESTVG1 successfully.

  Broadcast message from systemd-journald at localhost.localdomain (Tue 2021-02-23 21:55:16 EST):
  lvmlockctl[2032]: Runing lvmlockctl --drop TESTVG1.

  # dmsetup table
  TESTPV1: 0 163840 linear 8:146 0
  TESTVG1-TESTVG1LV1: 0 155648 error

Please be aware, to avoid misleading, I tested this with another
in-house locking scheme rather than sanlock, but the working flow for
failure handling is exactly same.

I have updated a bit for the two patches [1]; but want to check with you
how to proceed to merge these patches?  Would you directly merge patches
at your side or you want me to resend these two patches so you could
take a review before merging?  For the later case, I am glad to send the
patches to lvm-devel mailing list and follow up comments/suggestions as
needed.

Thanks,
Leo

[1] https://people.linaro.org/~leo.yan/lvm/


